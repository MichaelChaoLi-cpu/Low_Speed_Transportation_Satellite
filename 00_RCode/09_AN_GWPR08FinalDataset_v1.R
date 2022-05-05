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
library(doSNOW)

source("00_RCode/SP_07_AF_GWPRBandwidthStepSelection_v1.R")
load("04_Data/17_dataset_used.Tokyo.Control.Variables.01resolution.version2.RData")
points_mesh.in.Tokyo <- read.csv("04_Data/SP_00_points_mesh.in.Tokyo.RData")
proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 

xy <- points_mesh.in.Tokyo[,c(2,3)] ### remember here is csv, they have a index colunm
points_mesh.in.Tokyo <- SpatialPointsDataFrame(coords = xy, data = points_mesh.in.Tokyo,
                                               proj4string = CRS(proj))

formula <- lowSpeedDensity ~ 
  temp +  NDVI + ter_pressure +  precipitation +
  humidity + speedwind + shortWave + 
  prevalance + emergence

dataset_used.Tokyo <- dataset_used.Tokyo %>% 
  dplyr::select("GridID", "time", all.vars(formula)) %>% na.omit()

### search log movement bandwidth for 0.02 to 0.50, step is 0.005 
not_get_result <- T
if(not_get_result){
  message(formula)
  #formula <- lowSpeedDensity_num ~ temp +  NDVI + prevalance + emergence
  GWPR.FEM.bandwidth <- # this is about fixed bandwidth
    bw.GWPR.step.selection(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                           SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                           upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                           kernel = "bisquare", doParallel = T, cluster.number = 8, gradientIncrecement = T,
                           GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.015,  
                           address.output  =  "03_Results/8test_CV_F_9var_lowspeed_0015_05_0005.RData")
  GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
  save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.log.var8.0015.05.0005.Rdata")
  not_get_result <- F
}