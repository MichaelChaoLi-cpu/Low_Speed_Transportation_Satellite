# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(GWPR.light)
library(plm)
library(sp)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
dataset_Xshap <- read.csv('03_Results/mergedXSHAP.csv')


#### build sp dataset
point_dataset <- dataset_Xshap[,c(1,19,20)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))
points_mesh@data <- points_mesh@data %>% dplyr::select(GridID)

correlation_table <- cor(dataset_Xshap)
### Temperature 
formula <- Temperature_shap ~ Temperature

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

formula <- ter_pressure_shap ~ ter_pressure

GWPR.FEM.bandwidth.ter_pressure <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.ter_pressure, '03_Results/GWPR.FEM.bandwidth.ter_pressure.rds')
plot(GWPR.FEM.bandwidth.ter_pressure[,1], GWPR.FEM.bandwidth.ter_pressure[,2])

formula <- humidity_shap ~ humidity

GWPR.FEM.bandwidth.humidity <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.humidity, '03_Results/GWPR.FEM.bandwidth.humidity.rds')
plot(GWPR.FEM.bandwidth.humidity[,1], GWPR.FEM.bandwidth.humidity[,2])

formula <- precipitation_shap ~ precipitation

GWPR.FEM.bandwidth.precipitation <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.precipitation, '03_Results/GWPR.FEM.bandwidth.precipitation.rds')
plot(GWPR.FEM.bandwidth.precipitation[,1], GWPR.FEM.bandwidth.precipitation[,2])

formula <- speedwind_shap ~ speedwind

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

formula <- Temperature_shap ~ Temperature
plm_test(formula)
formula <- NTL_shap ~ NTL
plm_test(formula)
formula <- ter_pressure_shap ~ ter_pressure
plm_test(formula)
formula <- NDVI_shap ~ NDVI
plm_test(formula)
formula <- humidity_shap ~ humidity
plm_test(formula)
formula <- precipitation_shap ~ precipitation
plm_test(formula)
formula <- speedwind_shap ~ speedwind
plm_test(formula)
formula <- mg_m2_troposphere_no2_shap ~ mg_m2_troposphere_no2
plm_test(formula)
formula <- ozone_shap ~ ozone
plm_test(formula)
formula <- UVAerosolIndex_shap ~ UVAerosolIndex
plm_test(formula)
formula <- PBLH_shap ~ PBLH
plm_test(formula)














