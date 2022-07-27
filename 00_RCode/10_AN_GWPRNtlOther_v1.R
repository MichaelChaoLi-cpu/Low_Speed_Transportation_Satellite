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
library(foreach)
library(doSNOW)
library(parallel)

##### based on the SP_06_AN, We add this code to run  the code on the desktop
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

#formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence
formula <- NTL ~ lowSpeedDensity + temp +  NDVI + ter_pressure +  precipitation +  
  UVAerosolIndex + PBLH + prevalance + emergence

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
                           kernel = "bisquare", doParallel = T, cluster.number = 15, gradientIncrecement = T,
                           GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.015,  
                           address.output  =  "03_Results/15_laptop_F_8var_0015_05_0005.RData")
  GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
  save(GWPR.FEM.bandwidth.step.list, file = "03_Results/03_GWPR_BW_setp_list.Tokyo.ntl.var9.0015.05.0005.Rdata")
  plot(GWPR.FEM.bandwidth.step.list[,1], GWPR.FEM.bandwidth.step.list[,2])
  GWPR.FEM.bandwidth <- # this is about fixed bandwidth
    bw.GWPR.step.selection(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                           SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                           upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                           kernel = "bisquare", doParallel = T, cluster.number = 15, gradientIncrecement = T,
                           GI.step = 0.005, GI.upper = 1, GI.lower = 0.5,  
                           address.output  =  "03_Results/15_laptop_F_8var_05_1_0005.RData")
  not_get_result <- F
}

GWPR.FEM.CV.F.result.8var.0.015 <- 
  GWPR(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
       SDF = points_mesh.in.Tokyo, adaptive = F, p = 2,
       effect = "individual", kernel = "bisquare", longlat = F, 
       model = "within", bw = 0.015)

GWPR.FEM.CV.F.result.8var.0.015$SDF@data %>% View()
summary(GWPR.FEM.CV.F.result.8var.0.015$SDF@data$temp_TVa %>% as.numeric())

save(GWPR.FEM.CV.F.result.8var.0.015, file = "03_Results/02_GWPR.FEM.CV.F.result.8var.0.015.Rdata")

#### use lowSpeedDensity
formula_lowSpeedDensity <- lowSpeedDensity ~ NTL + temp +  NDVI + ter_pressure +  precipitation +  
  UVAerosolIndex + PBLH + prevalance + emergence
GWPR.FEM.bandwidth.lowSpeedDensity <- # this is about fixed bandwidth
  bw.GWPR.step.selection(formula = formula_lowSpeedDensity, data = dataset_used.Tokyo, index = c("GridID", "time"),
                         SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                         upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                         kernel = "bisquare", doParallel = T, cluster.number = 15, gradientIncrecement = T,
                         GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.015,  
                         address.output  =  "03_Results/15_laptop_F_8varformula_lowSpeedDensity_0015_05_0005.RData")
GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
save(GWPR.FEM.bandwidth.step.list, file = "03_Results/03_GWPR_BW_setp_list.Tokyo.ntl.var9.0015.05.0005.Rdata")

GWPR.FEM.CV.F.result.lowSpeedDensity.0.015 <- 
  GWPR(formula = formula_lowSpeedDensity, data = dataset_used.Tokyo, index = c("GridID", "time"),
       SDF = points_mesh.in.Tokyo, adaptive = F, p = 2,
       effect = "individual", kernel = "bisquare", longlat = F, 
       model = "within", bw = 0.015)
save(GWPR.FEM.CV.F.result.lowSpeedDensity.0.015, file = "03_Results/04_GWPR.FEM.CV.F.result.lowSpeedDensity.0.015.Rdata")
