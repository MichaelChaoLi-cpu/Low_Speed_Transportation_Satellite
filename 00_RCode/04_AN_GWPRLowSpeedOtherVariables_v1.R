# Author: M.L.

# end

library(tidyverse)
library(dplyr)
library(plm)
library(GWPR.light)
library(tmap)
library(sp)
library(doParallel)
library(foreach)

load("04_Data/02_panelLowSpeedDensityDataset.RData")
load("04_Data/03_dayTempRasterDataset.RData")
load("04_Data/05_NTLRasterDataset.RData")
load("04_Data/06_NDVIRasterDataset.RData")
load("04_Data/07_terrainPressureRasterDatasett.RData")
load("04_Data/08_humidityRasterDataset.RData")
load("04_Data/09_precipitationRasterDataset.RData")
load("04_Data/10_speedWindRasterDataset.RData")
load("04_Data/11_troposphereNo2RasterDataset.RData")
load("04_Data/12_TotalOzoneDURasterDataset.RData")
load("04_Data/13_UVAerosolIndexRasterDataset.RData")
load("04_Data/14_PBLHRasterDataset.RData")
load("04_Data/15_covid19PrefectureData.RData")
dataset_used <- left_join(panelLowSpeedDensityDataset, dayTempRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, NTLRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, terrainPressureRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, NDVIRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, humidityRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, precipitationRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, speedWindRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, troposphereNo2RasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, ozoneRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, UVAerosolIndexRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, PBLHRasterDataset, 
                          by = c("GridID", "year", "month"))
dataset_used <- left_join(dataset_used, covid19PrefectureData, 
                          by = c("GridID", "year", "month"))
dataset_used <- dataset_used %>%
  mutate(prevalance = ifelse(is.na(prevalance), 0, prevalance),
         mortality = ifelse(is.na(mortality), 0, mortality),
         emergence = ifelse(is.na(emergence), 0, emergence))

rm(panelLowSpeedDensityDataset, dayTempRasterDataset, 
   NTLRasterDataset, terrainPressureRasterDataset, NDVIRasterDataset, 
   humidityRasterDataset, precipitationRasterDataset, speedWindRasterDataset, 
   troposphereNo2RasterDataset, ozoneRasterDataset, UVAerosolIndexRasterDataset, 
   PBLHRasterDataset)
rm(covid19PrefectureData)

dataset_used$time <- dataset_used$year * 100 + dataset_used$month

save(dataset_used, file = "04_Data/00_datasetUsed.RData")

load("04_Data/00_datasetUsed.RData")
load("04_Data/00_points_mesh.in.GT.RData")
source("00_RCode/07_AF_GWPRBandwidthStepSelection_v1.R")

data.in.GT <- points_mesh.in.GT@data %>% 
  dplyr::select(GridID, PrefID)

dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)

formula <- lowSpeedDensity ~ 
  # nightTimeTemperature + humidity + ##these variables are highly related to day time temperature
  # speedwind + ## highly related to ter_pressure
  #speedwind + humidity +
  # NTL + # stage two
  temp + NDVI + 
  ter_pressure +  precipitation +  
  mg_m2_troposphere_no2 + ozone + UVAerosolIndex + PBLH +
  prevalance + emergence

formula <- NTL ~ lowSpeedDensity + NDVI

cor(dataset_used %>% dplyr::select(all.vars(formula)))

pdata <- pdata.frame(dataset_used, index = c("GridID", "time"))

ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)
fd <- plm(formula, pdata, model = "fd")
summary(fd)

pFtest(fem, ols)
phtest(fem, rem)
plmtest(ols, type = "bp")

rm(fem, ols, pdata, rem)

# we exiamine from the GWPR based on fem 
#GWPR.FEM.bandwidth <- # this is about fixed bandwidth
#  bw.GWPR.step.selection(formula = formula, data = dataset_used, index = c("GridID", "time"),
#                         SDF = points_mesh.in.GT, adaptive = F, p = 2, bigdata = F,
#                         upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
#                         kernel = "bisquare",doParallel = T, cluster.number = 6, gradientIncrecement = T,
#                         GI.step = 0.01, GI.upper = 0.125, GI.lower = 0.005)
#GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
#plot(GWPR.FEM.bandwidth.step.list[,1], GWPR.FEM.bandwidth.step.list[,2])

formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence
formula <- lowSpeedDensity ~   temp +  NDVI + ter_pressure +  precipitation +  
  UVAerosolIndex + PBLH + prevalance + emergence

points_mesh.in.Tokyo <- points_mesh.in.GT@data
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")

dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)

cor(dataset_used.Tokyo %>% dplyr::select(all.vars(formula)), use = "complete.obs")

pdata <- pdata.frame(dataset_used.Tokyo , index = c("GridID", "time"))

ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)

pFtest(fem, ols)
phtest(fem, rem)
plmtest(ols, type = "bp")

rm(fem, ols, pdata, rem)

xy <- points_mesh.in.Tokyo[,c(1,2)]
points_mesh.in.Tokyo <- SpatialPointsDataFrame(coords = xy, data = points_mesh.in.Tokyo,
                                               proj4string = points_mesh.in.GT@proj4string)

# we exiamine from the GWPR based on fem 
formula
GWPR.FEM.bandwidth <- # this is about fixed bandwidth
  bw.GWPR.step.selection(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                         SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                         upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                         kernel = "bisquare",doParallel = T, cluster.number = 6, gradientIncrecement = T,
                         GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.015)
#test 0.005 step length, from 0.015 degree
#GWPR.FEM.bandwidth.step.list <- rbind(GWPR.FEM.bandwidth.step.list, GWPR.FEM.bandwidth)
GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
plot(GWPR.FEM.bandwidth.step.list[,1], GWPR.FEM.bandwidth.step.list[,2])
save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.145.005.005.Rdata")

GWPR.FEM.bandwidth = 1.15 ###
################################ this is GWPR based on FEM
points_mesh.in.Tokyo@data <- points_mesh.in.Tokyo@data %>% rename("id"="GridID")
points_mesh.in.Tokyo@data <- points_mesh.in.Tokyo@data %>% dplyr::select(id)
GWPR.FEM.CV.F.result <- GWPR(formula = formula, data = dataset_used.Tokyo%>%rename("id"="GridID"), index = c("id", "time"),
                             SDF = points_mesh.in.Tokyo, bw = GWPR.FEM.bandwidth, adaptive = F,
                             p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                             model = "within")

GWPR.FEM.CV.F.result$SDF@data %>% View()
summary(GWPR.FEM.CV.F.result$SDF@data$temp_TVa %>% as.numeric())
save(GWPR.FEM.CV.F.result, file = "03_Results/GWPR_FEM_CV_F_result_1.15.Rdata")
