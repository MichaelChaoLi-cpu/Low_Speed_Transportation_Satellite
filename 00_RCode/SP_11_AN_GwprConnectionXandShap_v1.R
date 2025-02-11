# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(GWPR.light)
library(plm)
library(sp)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
dataset_Xshap <- read.csv('/home/usr6/q70176a/DP11/mergedXSHAP.csv')

#### build sp dataset
point_dataset <- dataset_Xshap[,c(1,18,19)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))

formula <- Temperature_shap ~ Temperature

GWPR.FEM.bandwidth.Temperature <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 30, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.1, GI.lower = 0.0025)
saveRDS(GWPR.FEM.bandwidth.Temperature, '03_Results/GWPR.FEM.bandwidth.Temperature.rds')
#plot(GWPR.FEM.bandwidth.Temperature[,1], GWPR.FEM.bandwidth.Temperature[,2])


points_mesh@data <- points_mesh@data %>% dplyr::select(GridID)
GWPR.FEM.CV.F.result <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
                             SDF = points_mesh, bw = 0.015, adaptive = F,
                             p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                             model = "pooling")

pdata <- pdata.frame(dataset_Xshap , index = c("GridID", "time"))

ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)

pFtest(fem, ols)
phtest(fem, rem)
plmtest(ols, type = "bp")