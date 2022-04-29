# Author: M.L.

# end

library(tidyverse)
library(dplyr)
library(plm)

dataset_used.Tokyo <- read.csv("04_Data/SP_00_dataset_used.Tokyo.RData")
dataset_used.Tokyo <- dataset_used.Tokyo %>% dplyr::select(-X)

formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence + NTL

dataset_used.Tokyo <- dataset_used.Tokyo %>% 
  dplyr::select(GridID, time, lowSpeedDensity, temp, NDVI, prevalance, emergence,
                NTL, lowSpeedDensity_num, year, month)

load("04_Data/07_terrainPressureRasterDatasett01.RData")
load("04_Data/08_humidityRasterDataset01.RData")
load("04_Data/09_precipitationRasterDataset01.RData")
load("04_Data/10_speedWindRasterDataset01.RData")
load("04_Data/16_shortWaveRasterDataset01.RData")

terrainPressureRasterDataset$GridID <- terrainPressureRasterDataset$GridID %>% as.numeric()
dataset_used.Tokyo <- left_join(dataset_used.Tokyo, terrainPressureRasterDataset,
                                by = c("GridID", "year", "month"))
humidityRasterDataset$GridID <- humidityRasterDataset$GridID %>% as.numeric()
dataset_used.Tokyo <- left_join(dataset_used.Tokyo, humidityRasterDataset,
                                by = c("GridID", "year", "month"))
precipitationRasterDataset$GridID <- precipitationRasterDataset$GridID %>% as.numeric()
dataset_used.Tokyo <- left_join(dataset_used.Tokyo, precipitationRasterDataset,
                                by = c("GridID", "year", "month"))
speedWindRasterDataset$GridID <- speedWindRasterDataset$GridID %>% as.numeric()
dataset_used.Tokyo <- left_join(dataset_used.Tokyo, speedWindRasterDataset,
                                by = c("GridID", "year", "month"))
shortWaveRasterDataset$GridID <- shortWaveRasterDataset$GridID %>% as.numeric()
dataset_used.Tokyo <- left_join(dataset_used.Tokyo, shortWaveRasterDataset, 
                                by = c("GridID", "year", "month"))

save(dataset_used.Tokyo, file = "17_dataset_used.Tokyo.Control.Variables.01resolution.version2.RData",
     version = 2)

### stage 1
formula <- lowSpeedDensity ~ 
  temp +  NDVI + ter_pressure +  precipitation +
  humidity + speedwind + shortWave + 
  prevalance + emergence

cor(dataset_used.Tokyo %>% dplyr::select(all.vars(formula)) %>% na.omit())

pdata <- pdata.frame(dataset_used.Tokyo, index = c("GridID", "time"))

ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)

pFtest(fem, ols)
rm(fem, ols, pdata, rem)

### stage 2
formula <- NTL ~ lowSpeedDensity + 
  temp +  NDVI + ter_pressure +  precipitation +
  humidity + speedwind + shortWave + 
  prevalance + emergence

cor(dataset_used.Tokyo %>% dplyr::select(all.vars(formula)) %>% na.omit())

pdata <- pdata.frame(dataset_used.Tokyo, index = c("GridID", "time"))

ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)

pFtest(fem, ols)
rm(fem, ols, pdata, rem)
