# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(GWPR.light)
library(plm)
library(sp)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
dataset_Xshap <- read.csv('03_Results/mergedXSHAP_noah.csv')


#### build sp dataset
point_dataset <- dataset_Xshap[,c(1,19,20)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))
points_mesh@data <- points_mesh@data %>% dplyr::select(GridID)

correlation_table <- cor(dataset_Xshap)
### Temperature 0.03
formula <- tair_shap ~ tair

GWPR.FEM.bandwidth.Temperature <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.Temperature, '03_Results/GWPR.FEM.bandwidth.Temperature.rds')
plot(GWPR.FEM.bandwidth.Temperature[,1], GWPR.FEM.bandwidth.Temperature[,2])

GWPR.FEM.CV.F.result.Temperature <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
                                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                                         model = "within")
saveRDS(GWPR.FEM.CV.F.result.Temperature, '03_Results/GWPR.FEM.CV.F.result.Temperature.rds')

###
formula <- NTL_shap ~ NTL

GWPR.FEM.bandwidth.NTL <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.06, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.NTL, '03_Results/GWPR.FEM.bandwidth.NTL.rds')
plot(GWPR.FEM.bandwidth.NTL[,1], GWPR.FEM.bandwidth.NTL[,2])

GWPR.FEM.CV.F.result.NTL <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
                                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                                         model = "within")
saveRDS(GWPR.FEM.CV.F.result.NTL, '03_Results/GWPR.FEM.CV.F.result.NTL.rds')

formula <- NDVI_shap ~ NDVI

GWPR.FEM.bandwidth.NDVI <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.NDVI, '03_Results/GWPR.FEM.bandwidth.NDVI.rds')
plot(GWPR.FEM.bandwidth.NDVI[,1], GWPR.FEM.bandwidth.NDVI[,2])

GWPR.FEM.CV.F.result.NDVI <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
                                 SDF = points_mesh, bw = 0.0075, adaptive = F,
                                 p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                                 model = "random")
saveRDS(GWPR.FEM.CV.F.result.NDVI, '03_Results/GWPR.FEM.CV.F.result.NDVI.rds')

formula <- psurf_shap ~ psurf #r2 0.57

GWPR.FEM.bandwidth.ter_pressure <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "pooling", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.ter_pressure, '03_Results/GWPR.FEM.bandwidth.ter_pressure.rds')
plot(GWPR.FEM.bandwidth.ter_pressure[,1], GWPR.FEM.bandwidth.ter_pressure[,2])

formula <- qair_shap ~ qair

GWPR.FEM.bandwidth.humidity <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.humidity, '03_Results/GWPR.FEM.bandwidth.humidity.rds')
plot(GWPR.FEM.bandwidth.humidity[,1], GWPR.FEM.bandwidth.humidity[,2])

formula <- rainf_shap ~ rainf

GWPR.FEM.bandwidth.precipitation <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.precipitation, '03_Results/GWPR.FEM.bandwidth.precipitation.rds')
plot(GWPR.FEM.bandwidth.precipitation[,1], GWPR.FEM.bandwidth.precipitation[,2])

formula <- wind_shap ~ wind

GWPR.FEM.bandwidth.speedwind <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.speedwind, '03_Results/GWPR.FEM.bandwidth.speedwind.rds')
plot(GWPR.FEM.bandwidth.speedwind[,1], GWPR.FEM.bandwidth.speedwind[,2])

#####
formula <- mg_m2_troposphere_no2_shap ~ mg_m2_troposphere_no2

GWPR.FEM.bandwidth.mg_m2_troposphere_no2 <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.mg_m2_troposphere_no2, '03_Results/GWPR.FEM.bandwidth.mg_m2_troposphere_no2.rds')
plot(GWPR.FEM.bandwidth.mg_m2_troposphere_no2[,1], GWPR.FEM.bandwidth.mg_m2_troposphere_no2[,2])

###### regression 
pdata <- pdata.frame(dataset_Xshap , index = c("GridID", "time"))

plm_test <- function(formula){
  ols <- plm(formula, pdata, model = "pooling")
  print("OLS:")
  print(summary(ols))
  fem <- plm(formula, pdata, model = "within")
  print("FEM:")
  print(summary(fem))
  rem <- plm(formula, pdata, model = "random")
  print("REM:")
  print(summary(rem))
  
  print("pFtest:")
  print(pFtest(fem, ols))
  print("Hausman:")
  print(phtest(fem, rem))
  print("plmtest:")
  print(plmtest(ols, type = "bp"))
}

formula <- tair_shap ~ tair
plm_test(formula)
formula <- NTL_shap ~ NTL
plm_test(formula)
formula <- psurf_shap ~ psurf
plm_test(formula)
formula <- NDVI_shap ~ NDVI
plm_test(formula)
formula <- qair_shap ~ qair
plm_test(formula)
formula <- rainf_shap ~ rainf
plm_test(formula)
formula <- wind_shap ~ wind
plm_test(formula)
formula <- mg_m2_troposphere_no2_shap ~ mg_m2_troposphere_no2
plm_test(formula)
formula <- ozone_shap ~ ozone
plm_test(formula)
formula <- UVAerosolIndex_shap ~ UVAerosolIndex
plm_test(formula)
formula <- PBLH_shap ~ PBLH
plm_test(formula)

#### second order test
dataset_X2shap <- dataset_Xshap
dataset_X2shap$tair2 <- dataset_X2shap$tair*dataset_X2shap$tair
formula <- tair_shap ~ tair + tair2
temp <- lm(formula, dataset_X2shap)
summary(temp)

dataset_X2shap$NTL2 <- dataset_X2shap$NTL *dataset_X2shap$NTL
formula <- NTL_shap ~ NTL + NTL2
NTL <- lm(formula, dataset_X2shap)
summary(NTL)

dataset_X2shap$psurf2 <- dataset_X2shap$psurf *dataset_X2shap$psurf
formula <- psurf_shap ~ psurf + psurf2
ter_pressure <- lm(formula, dataset_X2shap)
summary(ter_pressure)

dataset_X2shap$NDVI2 <- dataset_X2shap$NDVI *dataset_X2shap$NDVI
formula <- NDVI_shap ~ NDVI + NDVI2
NDVI <- lm(formula, dataset_X2shap)
summary(NDVI)

dataset_X2shap$qair2 <- dataset_X2shap$qair *dataset_X2shap$qair
formula <- humidity_shap ~ humidity + humidity2
humidity <- lm(formula, dataset_X2shap)
summary(humidity)

dataset_X2shap$precipitation2 <- dataset_X2shap$precipitation *dataset_X2shap$precipitation
formula <- qair_shap ~ qair + qair2
precipitation <- lm(formula, dataset_X2shap)
summary(precipitation)

dataset_X2shap$wind2 <- dataset_X2shap$wind *dataset_X2shap$wind
formula <- wind_shap ~ wind + wind2
speedwind <- lm(formula, dataset_X2shap)
summary(speedwind)

dataset_X2shap$mg_m2_troposphere_no2.2 <- dataset_X2shap$mg_m2_troposphere_no2 *dataset_X2shap$mg_m2_troposphere_no2
formula <- mg_m2_troposphere_no2_shap ~ mg_m2_troposphere_no2 + mg_m2_troposphere_no2.2
mg_m2_troposphere_no2 <- lm(formula, dataset_X2shap)
summary(mg_m2_troposphere_no2)

dataset_X2shap$ozone2 <- dataset_X2shap$ozone *dataset_X2shap$ozone
formula <- ozone_shap ~ ozone + ozone2
ozone <- lm(formula, dataset_X2shap)
summary(ozone)

dataset_X2shap$UVAerosolIndex2 <- dataset_X2shap$UVAerosolIndex *dataset_X2shap$UVAerosolIndex
formula <- UVAerosolIndex_shap ~ UVAerosolIndex + UVAerosolIndex2
UVAerosolIndex <- lm(formula, dataset_X2shap)
summary(UVAerosolIndex)

dataset_X2shap$PBLH2 <- dataset_X2shap$PBLH *dataset_X2shap$PBLH
formula <- PBLH_shap ~ PBLH + PBLH2
PBLH <- lm(formula, dataset_X2shap)
summary(PBLH)

point_dataset <- dataset_Xshap[,c(1,19,20)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))
points_mesh@data <- points_mesh@data %>% dplyr::select(GridID)

formula <- Temperature_shap ~ Temperature + Temperature2
GWPR.FEM.bandwidth.Temperature <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_X2shap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "pooling", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
















