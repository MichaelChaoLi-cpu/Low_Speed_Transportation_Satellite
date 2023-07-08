# Author: M.L.


# end

library(dplyr)
library(sp)
library(tidyverse)

mean_std <- read.csv('04_Data/98_DatasetWithNoah.csv')
mean_std_agg <- mean_std %>% dplyr::select('GridID', 'lowSpeedDensity',  
                                           'tair', 'psurf', 'qair', 'wind', 'rainf',
                                           'NTL', 'NDVI', 'PBLH')
std_agg <- aggregate(mean_std_agg, by = list(mean_std_agg$GridID), sd) %>%
  dplyr::select(-GridID) %>% rename('GridID' = 'Group.1')

### tair
GWPR.result.tair <- readRDS('12_Results0618/02.GWPR.result.tair.rds')
tair.local.coef <- GWPR.result.tair$SDF@data %>% rename('tair.coeff' = 'tair',
                                                        'GridID' = 'id') %>%
  dplyr::select('GridID', 'tair.coeff')

tair.ana <- left_join(tair.local.coef, std_agg)
# 1 degree
tair.ana$degree1.LSD <- 1/tair.ana$tair * tair.ana$tair.coeff * tair.ana$lowSpeedDensity 
summary(tair.ana$degree1.LSD)
sum(tair.ana$degree1.LSD)

### wind
GWPR.result.wind <- readRDS('12_Results0618/02.GWPR.result.wind.rds')
wind.local.coef <- GWPR.result.wind$SDF@data %>% rename('wind.coeff' = 'wind',
                                                        'GridID' = 'id') %>%
  dplyr::select('GridID', 'wind.coeff')

wind.ana <- left_join(wind.local.coef, std_agg)
# 1 m/s
wind.ana$degree1.LSD <- 1/wind.ana$wind * wind.ana$wind.coeff * wind.ana$lowSpeedDensity 
summary(wind.ana$degree1.LSD)
sum(wind.ana$degree1.LSD)

### air pressure
GWPR.result.psurf <- readRDS('12_Results0618/02.GWPR.result.psurf.rds')
psurf.local.coef <- GWPR.result.psurf$SDF@data %>% rename('psurf.coeff' = 'psurf',
                                                        'GridID' = 'id') %>%
  dplyr::select('GridID', 'psurf.coeff')

psurf.ana <- left_join(psurf.local.coef, std_agg)
# 1kpa
psurf.ana$degree1.LSD <- 1/psurf.ana$psurf * psurf.ana$psurf.coeff * psurf.ana$lowSpeedDensity 
summary(psurf.ana$degree1.LSD)
sum(psurf.ana$degree1.LSD)

### qair
GWPR.result.qair <- readRDS('12_Results0618/02.GWPR.result.qair.rds')
qair.local.coef <- GWPR.result.qair$SDF@data %>% rename('qair.coeff' = 'qair',
                                                          'GridID' = 'id') %>%
  dplyr::select('GridID', 'qair.coeff')

qair.ana <- left_join(qair.local.coef, std_agg)
# 1g/kg
qair.ana$degree1.LSD <- 0.001/qair.ana$qair * qair.ana$qair.coeff * qair.ana$lowSpeedDensity 
summary(qair.ana$degree1.LSD)
sum(qair.ana$degree1.LSD)

### rainf
GWPR.result.rainf <- readRDS('12_Results0618/02.GWPR.result.rainf.rds')
rainf.local.coef <- GWPR.result.rainf$SDF@data %>% rename('rainf.coeff' = 'rainf',
                                                        'GridID' = 'id') %>%
  dplyr::select('GridID', 'rainf.coeff')

rainf.ana <- left_join(rainf.local.coef, std_agg)
# 0.000001 kg/(m2*s)
rainf.ana$degree1.LSD <- 0.00001/rainf.ana$rainf * rainf.ana$rainf.coeff * rainf.ana$lowSpeedDensity 
summary(rainf.ana$degree1.LSD)
sum(rainf.ana$degree1.LSD)

