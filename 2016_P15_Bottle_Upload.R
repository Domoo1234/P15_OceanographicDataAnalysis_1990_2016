#2016 P15 Bottle data

library(ncdf4)
library(tidyverse)
library(tidync)
library(ggplot2)
setwd("xxx")

# Explore datasets from P15S

# Other datasets
# nc_ctd <- nc_open("096U20160426_ctd.nc")
# bottle_csv <- read_csv("096U20160426_hy1.csv")

### EXPLORE BOTTLE DATA ###

nc_bottle <- tidync("096u20160426_bottle.nc")

names(nc_bottle$var)

# Explore bottle data for nutrients
nc_bottle |>
  hyper_grids(nc_bottle)

# Convert to tibble

bottle_data <- nc_bottle |>
  activate("D4,D0") |>
  hyper_tibble()

# Explore variables

nc_bottle |> 
  activate("D4,D0") |>
  hyper_vars()

# Extract Station data

stn_bottle <- nc_bottle |>
  activate("D0") |>
  hyper_tibble()

# Join station metadata to bottle data

bottle_data <- bottle_data |>
  left_join(stn_bottle, by = "N_PROF")

# Explore column vars

names(bottle_data) 

# Just checking - 
# "latitude" %in% names(bottle_data)
# unique(bottle_data$N_PROF)

# Select by station, not overly useful
# Note - stations listed under N_PROF

bottle_data |>
  filter(N_PROF == 1) |>
  ggplot(aes(ctd_temperature, pressure)) +
  geom_path() +
  scale_y_reverse()

# Filter readings by latitude to highlight different 'flavours'
# of AAIW - change as needed then use below code to generate
# plots

lat1 <- -25
lat2 <- -40

bottle_section <- bottle_data |>
  filter(latitude < lat1 & 
           latitude > lat2)
  
# Plot temperature vs depth for MidAAIW
# Note - Pressure is proxy for depth

# Plot nutrients vs depth 

ggplot(bottle_section,
       aes(x = nitrate,
           y = pressure,
           colour = latitude)) +
  
  geom_point(alpha = 0.6, size = 0.8) +
  scale_y_reverse() +
  scale_colour_viridis_c(option = "C") +
  
  labs(
    x = "Nitrate (µmol/kg)",
    y = "Pressure (dbar)",
    colour = "Latitude",
    title = sprintf("Nitrate Profile: %.1fS to %.1fS",
                    lat1, lat2)
  ) +
  theme_bw()

# Plot Oxygen vs depth 

ggplot(bottle_section,
       aes(x = oxygen,
           y = pressure,
           colour = latitude)) +
  
  geom_point(alpha = 0.6, size = 0.8) +
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

