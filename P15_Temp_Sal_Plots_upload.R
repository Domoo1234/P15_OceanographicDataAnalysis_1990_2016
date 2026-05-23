### Temperature and salinity trends for all years (faceted with trend stats)

# -----------------------------
# Required libraries
# -----------------------------
library(tidyverse)
library(tidync)
library(broom)
library(ggplot2)
library(dplyr)
library(tidyr)

# -----------------------------
# Working directory
# -----------------------------
setwd("xxx")

# -----------------------------
# Function: Process CTD NetCDF files (1990, 1996, 2001, 2009, 2016)
# -----------------------------
process_ctd_year <- function(nc_file, year) {
  
  nc_ctd <- tidync(nc_file)
  
  # Auto-detect CTD grid (2 dims, many vars)
  grids <- nc_ctd |> hyper_grids()
  ctd_grid <- grids |> 
    filter(ndims == 2, nvars >= 5) |> 
    slice(1) |> 
    pull(grid)
  
  # Extract CTD depth data
  ctd_data <- nc_ctd |>
    activate(ctd_grid) |>
    hyper_tibble()
  
  # Extract station metadata
  stn_ctd <- nc_ctd |>
    activate("D0") |>
    hyper_tibble()
  
  # Join metadata
  ctd_data <- ctd_data |>
    left_join(stn_ctd, by = "N_PROF")
  
  # Filter to depth + latitude bands
  ctd_filtered <- ctd_data |>
    mutate(latitude = as.numeric(latitude)) |>
    filter(
      pressure >= 500,
      pressure <= 1000,
      (
        (latitude <= 0   & latitude >= -20) |
          (latitude <= -25 & latitude >= -40) 
      )
    )
  
  # Summarise by latitude band
  summary <- ctd_filtered |>
    mutate(
      lat_band = case_when(
        latitude <= 0   & latitude >= -20 ~ "0 to -20°",
        latitude <= -25 & latitude >= -40 ~ "-25 to -40°"
      )
    ) |>
    group_by(lat_band) |>
    summarise(
      mean_temperature = mean(ctd_temperature, na.rm = TRUE),
      mean_salinity = mean(ctd_salinity, na.rm = TRUE),
      mean_oxygen = mean(ctd_oxygen, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      lat_band = factor(lat_band, levels = c("0 to -20°", "-25 to -40°")),
      year = year
    )
  
  return(summary)
}

# -----------------------------
# Function: Process BOTTLE NetCDF files (1990 only)
# -----------------------------
process_bottle_year <- function(nc_file, year) {
  
  nc_bottle <- tidync(nc_file)
  
  # Bottle data grid
  bottle_data <- nc_bottle |>
    activate("D4,D0") |>
    hyper_tibble()
  
  # Station metadata (contains latitude)
  stn_bottle <- nc_bottle |>
    activate("D0") |>
    hyper_tibble()
  
  # Join metadata (adds latitude + longitude)
  bottle_data <- bottle_data |>
    left_join(stn_bottle, by = "N_PROF")
  
  # Filter to depth + latitude bands
  bottle_filtered <- bottle_data |>
    mutate(latitude = as.numeric(latitude)) |>
    filter(
      pressure >= 500,
      pressure <= 1000,
      (
        (latitude <= 0   & latitude >= -20) |
          (latitude <= -25 & latitude >= -40) 
      )
    )
  
  # Summarise by latitude band
  summary <- bottle_filtered |>
    mutate(
      lat_band = case_when(
        latitude <= 0   & latitude >= -20 ~ "0 to -20°",
        latitude <= -25 & latitude >= -40 ~ "-25 to -40°"
      )
    ) |>
    group_by(lat_band) |>
    summarise(
      mean_temperature = mean(ctd_temperature, na.rm = TRUE),
      mean_salinity = mean(ctd_salinity, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      lat_band = factor(lat_band, levels = c("0 to -20°", "-25 to -40°")),
      year = year
    )
  
  return(summary)
}

# -----------------------------
# Load all years
# -----------------------------
summary_2016 <- process_ctd_year("096U20160426_ctd.nc", 2016)
summary_2009 <- process_ctd_year("09SS20090203_ctd_2009.nc", 2009)
summary_2001 <- process_ctd_year("09FA20010524_ctd_2001.nc", 2001)
summary_1996 <- process_ctd_year("31DSCG96_1_ctd_1996.nc", 1996)
summary_1990 <- process_bottle_year("3175CG90_1_bottle.nc", 1990)

ctd_all_years <- bind_rows(
  summary_2016,
  summary_2009,
  summary_2001,
  summary_1996,
  summary_1990
)

# -----------------------------
# Reshape to long format
# -----------------------------
ctd_long <- ctd_all_years |>
  pivot_longer(
    cols = c(mean_temperature, mean_salinity, mean_oxygen),
    names_to = "variable",
    values_to = "value"
  )

# -----------------------------
# Compute slope + R² per lat band per variable
# -----------------------------
trend_stats <- ctd_long |>
  group_by(lat_band, variable) |>
  do({
    m <- lm(value ~ year, data = .)
    tibble(
      slope = coef(m)[2],
      r2 = summary(m)$r.squared
    )
  })

# -----------------------------
# Merge stats back into plotting data
# -----------------------------
ctd_plot <- ctd_long |>
  left_join(trend_stats, by = c("lat_band", "variable")) |>
  mutate(
    lat_band = recode(
      lat_band,
      "0 to -20°" = "EqPac IW (0 to -20°)",
      "-25 to -40°" = "AAIW (-25 to -40°)"
    )
  ) |>
  mutate(
    facet_label = sprintf(
      "%s\nSlope: %.3f | R²: %.2f",
      lat_band, slope, r2
    )
  )

# -----------------------------
# Faceted Temperature Plot
# -----------------------------
temp_plot <- ggplot(
  ctd_plot |> filter(variable == "mean_temperature"),
  aes(x = year, y = value)
) +
  geom_point(colour = "blue", size = 2) +
  geom_line(colour = "blue", linewidth = 0.5) +
  geom_text(aes(label = year), vjust = -0.5, size = 3) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = 0.3) +
  facet_wrap(~ facet_label, ncol = 1) +
  labs(
    x = "Year",
    y = "Mean Temperature (°C)",
    title = "Temperature Trends (500–1000 m)"
  ) +
  theme_bw()

# -----------------------------
# Faceted Salinity Plot
# -----------------------------
sal_plot <- ggplot(
  ctd_plot |> filter(variable == "mean_salinity"),
  aes(x = year, y = value)
) +
  geom_point(colour = "darkorange", size = 2) +
  geom_line(colour = "darkorange", linewidth = 0.5) +
  geom_text(aes(label = year), vjust = -0.5, size = 3) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = 0.3) +
  facet_wrap(~ facet_label, ncol = 1) +
  labs(
    x = "Year",
    y = "Mean Salinity (PSU)",
    title = "Salinity Trends (500–1000 m)"
  ) +
  theme_bw()

# -----------------------------
# Faceted Oxygen Plot
# -----------------------------
oxy_plot <- ggplot(
  ctd_plot |> filter(variable == "mean_oxygen"),
  aes(x = year, y = value)
) +
  geom_point(colour = "purple", size = 2) +
  geom_line(colour = "purple", linewidth = 0.5) +
  geom_text(aes(label = year), vjust = -0.5, size = 3) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = 0.3) +
  facet_wrap(~ facet_label, ncol = 1) +
  labs(
    x = "Year",
    y = "Mean Oxygen (µmol/kg)",
    title = "Oxygen Trends (500–1000 m)"
  ) +
  theme_bw()

# -----------------------------
# Display plots
# -----------------------------
temp_plot
sal_plot
oxy_plot
