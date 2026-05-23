# 2016 P15 data

# -----------------------------
# Required libraries
# -----------------------------

library(ncdf4)
library(tidyverse)
library(tidync)
library(tidyr)
library(ggplot2)
library(dplyr)


setwd("xxx")

# Explore datasets from P15S

# Other datasets
# bottle_csv <- read_csv("096U20160426_hy1.csv")

### EXPLORE BOTTLE DATA ###

nc_ctd <- tidync("096U20160426_ctd.nc")

names(nc_ctd$var)

# Explore bottle data for nutrients
nc_ctd |>
  hyper_grids(nc_ctd)

# Convert to tibble

ctd_data <- nc_ctd |>
  activate("D4,D0") |>
  hyper_tibble()

# Explore variables

nc_ctd |> 
  activate("D4,D0") |>
  hyper_vars()

# Extract Station data

stn_ctd <- nc_ctd |>
  activate("D0") |>
  hyper_tibble()

# Join station metadata to bottle data

ctd_data <- ctd_data |>
  left_join(stn_ctd, by = "N_PROF")

# Explore column vars

names(ctd_data) 

# Just checking - 
# "latitude" %in% names(ctd_data)
# unique(ctd_data$N_PROF)

# Select by station, not overly useful
# Note - stations listed under N_PROF

ctd_data |>
  filter(N_PROF == 1) |>
  ggplot(aes(ctd_temperature, pressure)) +
  geom_path() +
  scale_y_reverse()

# Filter readings by latitude to highlight different 'flavours'
# of AAIW - change as needed then use below code to generate
# plots

lat1 <- -0
lat2 <- -25

ctd_section <- ctd_data |>
  filter(latitude < lat1 & 
           latitude > lat2)

# Plot temperature vs depth for MidAAIW
# Note - Pressure is proxy for depth

ggplot(ctd_section,
       aes(x = ctd_temperature,
           y = pressure,
           colour = latitude)) +
  
  geom_point(alpha = 0.6, size = 0.5) +
  scale_y_reverse() +
  scale_colour_viridis_c(option = "C") +
  
  labs(
    x = "Temperature (°C)",
    y = "Pressure (dbar)",
    colour = "Latitude",
    title = sprintf("Temperature Profile: %.1f°S to %.1f°S",
                    lat1, lat2)
  ) +
  theme_bw()


# Plot salinity vs depth 

ggplot(ctd_section,
       aes(x = ctd_salinity,
           y = pressure,
           colour = latitude)) +
  
  geom_point(alpha = 0.6, size = 0.5) +
  scale_y_reverse() +
  scale_colour_viridis_c(option = "C") +
  
  labs(
    x = "Salinty (PSU)",
    y = "Pressure (dbar)",
    colour = "Latitude",
    title = sprintf("Salinity Profile: %.1fS to %.1fS",
                    lat1, lat2)
  ) +
  theme_bw()

# Plot Oxygen vs depth 

ggplot(ctd_section,
       aes(x = ctd_oxygen,
           y = pressure,
           colour = latitude)) +
  
  geom_point(alpha = 0.6, size = 0.5) +
  scale_y_reverse() +
  scale_colour_viridis_c(option = "C") +
  
  labs(
    x = "Oxygen (µmol/kg)",
    y = "Pressure (dbar)",
    colour = "Latitude",
    title = sprintf("Oxygen Profile: %.1fS to %.1fS",
                    lat1, lat2)
  ) +
  theme_bw()

##### Getting averages for temperature and salinity

# Create a machine readable dataset for AI

ctd_data <- nc_ctd |>
  activate("D4,D0") |>
  hyper_tibble()

stn_ctd <- nc_ctd |>
  activate("D0") |>
  hyper_tibble()

ctd_data <- ctd_data |>
  left_join(stn_ctd, by = "N_PROF")


# Filter to reduce file size
# Iportant - remember to change filename for different years

ctd_filtered_2016 <- ctd_data |>
  mutate(latitude = as.numeric(latitude)) |>
  filter(
    pressure >= 500,
    pressure <= 1000,
    (
      (latitude <= 0   & latitude >= -20) |
        (latitude <= -25 & latitude >= -40) |
        (latitude <= -45 & latitude >= -55)
    )
  ) |>
  select(
    latitude, longitude,
    pressure, ctd_temperature, ctd_salinity
  )

# Create a temperature plot for 2016 data

temp_2016 <- ctd_filtered_2016 |>
  mutate(
    lat_band = case_when(
      latitude <= 0   & latitude >= -20 ~ "0 to -20°",
      latitude <= -25 & latitude >= -40 ~ "-25 to -40°",
      latitude <= -45 & latitude >= -55 ~ "-45 to -55°"
    )
  ) |>
  group_by(lat_band) |>
  summarise(
    mean_temperature = mean(ctd_temperature, na.rm = TRUE)
  )

# Required to display latitudes in correct order

temp_2016$lat_band <- factor(
  temp_2016$lat_band,
  levels = c("0 to -20°", "-25 to -40°", "-45 to -55°")
)

# Plot temperature 

ggplot(temp_2016, aes(x = lat_band, y = mean_temperature, group = 1)) +
  geom_line(linewidth = 1.2, colour = "steelblue") +
  geom_point(size = 3, colour = "steelblue") +
  labs(
    x = "Latitude Band",
    y = "Mean Temperature (°C)",
    title = "Mean Temperature (500–1000 meters, 2016)"
  ) +
  theme_bw()


# Create a salinity plot for 2016 data

sal_2016 <- ctd_filtered_2016 |>
  mutate(
    lat_band = case_when(
      latitude <= 0   & latitude >= -20 ~ "0 to -20°",
      latitude <= -25 & latitude >= -40 ~ "-25 to -40°",
      latitude <= -45 & latitude >= -55 ~ "-45 to -55°"
    )
  ) |>
  group_by(lat_band) |>
  summarise(
    mean_salinity = mean(ctd_salinity, na.rm = TRUE)
  )

sal_2016$lat_band <- factor(
  sal_2016$lat_band,
  levels = c("0 to -20°", "-25 to -40°", "-45 to -55°")
)

# Plot salinity

ggplot(sal_2016, aes(x = lat_band, y = mean_salinity, group = 1)) +
  geom_line(linewidth = 1.2, colour = "darkorange") +
  geom_point(size = 3, colour = "darkorange") +
  labs(
    x = "Latitude Band",
    y = "Mean Salinity (PSU)",
    title = "Mean Salinity (500–1000 meters, 2016)"
  ) +
  theme_bw()

