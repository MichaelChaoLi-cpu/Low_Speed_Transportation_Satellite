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

#GWPR.FEM.CV.F.result <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
#                             SDF = points_mesh, bw = 0.015, adaptive = F,
#                             p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
#                             model = "pooling")


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

formula <- NDVI_shap ~ NDVI

GWPR.FEM.bandwidth.NDVI <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.NDVI, '03_Results/GWPR.FEM.bandwidth.NDVI.rds')
plot(GWPR.FEM.bandwidth.NDVI[,1], GWPR.FEM.bandwidth.NDVI[,2])

formula <- ter_pressure_shap ~ ter_pressure

GWPR.FEM.bandwidth.ter_pressure <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.061, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.ter_pressure_shap, '03_Results/GWPR.FEM.bandwidth.ter_pressure.rds')
plot(GWPR.FEM.bandwidth.ter_pressure[,1], GWPR.FEM.bandwidth.ter_pressure[,2])

