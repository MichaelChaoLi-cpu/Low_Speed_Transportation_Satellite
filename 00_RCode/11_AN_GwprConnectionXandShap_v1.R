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
point_dataset <- dataset_Xshap[,c(1,18,19)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))

formula <- Temperature_shap ~ Temperature

GWPR.FEM.bandwidth.Temperature <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "pooling", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.2, GI.lower = 0.0025)

