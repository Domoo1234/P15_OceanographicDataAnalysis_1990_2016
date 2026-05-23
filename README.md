[P15_OceanographicDataAnalysis_Readme.md](https://github.com/user-attachments/files/28184590/P15_OceanographicDataAnalysis_Readme.md)
# P15 Oceanographic Data Analysis (1990–2016)

This repository contains reproducible R scripts used to analyse multi‑decadal changes in Antarctic Intermediate Water (AAIW) along the GO‑SHIP P15S transect. The project compares temperature, salinity, and oxygen structure between five hydrographic occupations (1990, 1996, 2001, 2009, 2016) to assess long‑term changes in intermediate‑depth water masses in the South Pacific.

This repository was created to support a university research project analysing long‑term changes in Antarctic Intermediate Water along the P15S transect. All code is fully reproducible and designed for transparency in oceanographic data processing.

---

## Overview

The GO‑SHIP P15S line (≈170°W) provides repeated full‑depth hydrographic measurements from the Antarctic sea‑ice edge to the equator. This project:

- Extracts CTD and bottle data from NetCDF files  
- Standardises variables across cruises  
- Defines Regions of Interest (ROIs) based on AAIW “flavours”  
- Compares 1996 vs 2016 profiles (0–1000 m)  
- Computes multi‑decadal trends (1990–2016) in the AAIW core (500–1000 m)  
- Produces publication‑quality figures for temperature, salinity, and oxygen  

---

## Repository Structure

/scripts
├── 2016_P15_CTD_upload.R
├── 1996_2016_comparison_upload.R
└── P15_Temp_Sal_Plots_upload.R

/figures
(generated plots saved here)

/data
(NetCDF files not included due to size; available from CCHDO)


---

## Required R Packages

```r
tidyverse
tidync
ncdf4
ggplot2
dplyr
broom
tidyr

Script Descriptions
1. 2016_P15_CTD_upload.R
Loads and explores the 2016 CTD dataset.
Key steps:

Reads NetCDF using tidync

Extracts CTD variables + station metadata

Filters by depth (500–1000 m) and latitude bands

Generates T/S/O₂ profiles for selected ROIs

Computes mean temperature and salinity for each latitude band

2. 1996_2016_comparison_upload.R
Direct comparison of 1996 and 2016 CTD profiles.
Key steps:

Loads both NetCDF files using a helper function

Auto‑detects CTD grids

Merges datasets and filters to 0–1000 m

User‑defined latitude window

Produces overlaid comparison plots for:

Temperature vs pressure

Salinity vs pressure

Oxygen vs pressure

3. P15_Temp_Sal_Plots_upload.R
Full multi‑decadal trend analysis (1990–2016).
Key steps:

Processes CTD NetCDF files for 1996–2016

Processes bottle data for 1990

Extracts and standardises variables

Filters to AAIW core (500–1000 m)

Computes mean T/S/O₂ per ROI per year

Fits linear models to calculate slope + R²

Produces faceted trend plots with annotated statistics

4. 2016_P15_Bottle_upload.R
Loads and analyses the 2016 bottle dataset, including nutrients.
Key steps:

Reads bottle NetCDF file using tidync

Extracts bottle variables (nitrate, oxygen, salinity, temperature, etc.)

Joins station metadata (lat/lon) via N_PROF

Filters by latitude band and depth (pressure as proxy)

Produces nutrient and oxygen profiles (e.g., nitrate vs depth, oxygen vs depth)

Supports identification of AAIW signatures using bottle‑sample variables

Regions of Interest (ROIs)
Defined following Bostock et al. (2013):

EqPac IW: 0 to –20°

AAIW (Tasman): –25 to –40°

SO IW: –45 to –55° (excluded due to mixing)

Final analyses use EqPac and AAIW only.

Data Sources
Data obtained from the CLIVAR and Carbon Hydrographic Data Office (CCHDO): https://cchdo.ucsd.edu/


if using this repository, please cite:

Reitano, D. (2026). P15 Oceanographic Data Analysis (1990–2016). GitHub.
Available at: https://github.com/Domoo1234/P15_OceanographicDataAnalysis_1990_2016
