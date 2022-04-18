# Author: M.L.


# Note: this script is used for Supercomputer 
# Tip: remember the package version should be consistent with R version on SuperCom.
# Tip: package "doParallel" does not work on Linux.

# end

library(tidyverse)
library(dplyr)
library(plm)
#library(GWPR.light)
library(sp)
library(doParallel)
library(foreach)
library(doSNOW)

source("00_RCode/SP_07_AF_GWPRBandwidthStepSelection_v1.R")
#points_mesh.in.Tokyo <- read.csv("04_Data/SP_00_points_mesh.test.RData")
#dataset_used.Tokyo <- read.csv("04_Data/SP_00_dataset_used.test.RData")
points_mesh.in.Tokyo <- read.csv("04_Data/SP_00_points_mesh.in.Tokyo.RData")
dataset_used.Tokyo <- read.csv("04_Data/SP_00_dataset_used.Tokyo.RData")
proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 

xy <- points_mesh.in.Tokyo[,c(2,3)] ### remember here is csv, they have a index colunm
points_mesh.in.Tokyo <- SpatialPointsDataFrame(coords = xy, data = points_mesh.in.Tokyo,
                                               proj4string = CRS(proj))
message("data done")

formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence

### search log movement bandwidth for 0.02 to 0.50, step is 0.005 
not_get_result <- T
if(not_get_result){
  message(formula)
  #formula <- lowSpeedDensity_num ~ temp +  NDVI + prevalance + emergence
  GWPR.FEM.bandwidth <- # this is about fixed bandwidth
    bw.GWPR.step.selection(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                           SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                           upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                           kernel = "bisquare", doParallel = T, cluster.number = 36, gradientIncrecement = T,
                           GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.02)
  GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
  save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.log.002.05.0005.Rdata")
  not_get_result <- F
}
