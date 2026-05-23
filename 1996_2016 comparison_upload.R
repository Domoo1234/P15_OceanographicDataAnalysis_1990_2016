# Comparison between 1996 and 2016 datasets of P15 voyage

library(tidyverse)
library(tidync)
library(ggplot2)
library(dplyr)

setwd("xxx")

### -----------------------------
### Helper function to load CTD
### -----------------------------
load_ctd <- function(nc_file, year) {
  
  nc <- tidync(nc_file)
  
  # Auto-detect CTD grid
  grids <- nc |> hyper_grids()
  ctd_grid <- grids |> filter(ndims == 2, nvars >= 5) |> slice(1) |> pull(grid)
  
  # Extract CTD data
  ctd <- nc |>
    activate(ctd_grid) |>
    hyper_tibble()
  
  # Extract station metadata
  stn <- nc |>
    activate("D0") |>
    hyper_tibble()
  
  # Join metadata
  ctd <- ctd |> left_join(stn, by = "N_PROF")
  
  # Add year
  ctd$year <- year
  
  return(ctd)
}

### -----------------------------
### Load 1996 + 2016 datasets
### -----------------------------
ctd_1996 <- load_ctd("31DSCG96_1_ctd_1996.nc", 1996)
ctd_2016 <- load_ctd("096U20160426_ctd.nc", 2016)

### -----------------------------
### Combine datasets
### -----------------------------
ctd_all <- bind_rows(ctd_1996, ctd_2016)

### -----------------------------
### USER-DEFINED LATITUDE FILTER
### -----------------------------
# Set your latitude bounds here:
lat_max <- -20
lat_min <- -40

ctd_filtered <- ctd_all |>
  mutate(pressure = as.numeric(pressure)) |>
  filter(
    !is.na(pressure),
    pressure > 0,
    pressure <= 1000,
    latitude >= lat_min,
    latitude <= lat_max
  )

### -----------------------------
### Temperature comparison plot
### -----------------------------
temp_comp <- ggplot(ctd_filtered,
                    aes(x = ctd_temperature,
                        y = pressure,
                        colour = factor(year))) +
  geom_point(alpha = 0.4, size = 0.7) +
#  geom_smooth(se = FALSE, linewidth = 1) +
  scale_y_reverse() +
  scale_colour_manual(values = c("1996" = "purple", "2016" = "orange")) +
  labs(
    x = "Temperature (°C)",
    y = "Pressure (dbar)",
    colour = "Year",
    title = sprintf("Temperature Comparison (0–1000 m)\nLat %.1f° to %.1f°",
                    lat_max, lat_min)
  ) +
  theme_bw()

### -----------------------------
### Salinity comparison plot
### -----------------------------
sal_comp <- ggplot(ctd_filtered,
                   aes(x = ctd_salinity,
                       y = pressure,
                       colour = factor(year))) +
  geom_point(alpha = 0.4, size = 0.7) +
#  geom_smooth(se = FALSE, linewidth = 1) +
  scale_y_reverse() +
  scale_colour_manual(values = c("1996" = "purple", "2016" = "orange")) +
  labs(
    x = "Salinity (PSU)",
    y = "Pressure (dbar)",
    colour = "Year",
    title = sprintf("Salinity Comparison (0–1000 m)\nLat %.1f° to %.1f°",
                    lat_max, lat_min)
  ) +
  theme_bw()

### -----------------------------
### Oxygen comparison plot
### -----------------------------
oxy_comp <- ggplot(ctd_filtered,
                   aes(x = ctd_oxygen,
                       y = pressure,
                       colour = factor(year))) +
  geom_point(alpha = 0.4, size = 0.7) +
#  geom_smooth(se = FALSE, linewidth = 1) +
  scale_y_reverse() +
  scale_colour_manual(values = c("1996" = "purple", "2016" = "orange")) +
  labs(
    x = "Oxygen (µmol/kg)",
    y = "Pressure (dbar)",
    colour = "Year",
    title = sprintf("Oxygen Comparison (0–1000 m)\nLat %.1f° to %.1f°",
                    lat_max, lat_min)
  ) +
  theme_bw()

### -----------------------------
### Display plots
### -----------------------------
temp_comp
sal_comp
oxy_comp

