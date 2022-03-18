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

load("04_Data/00_datasetUsed.RData")
load("04_Data/00_points_mesh.in.GT.RData")
source("00_RCode/07_AF_GWPRBandwidthStepSelection_v1.R")

data.in.GT <- points_mesh.in.GT@data %>% 
  dplyr::select(GridID, PrefID)

dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)

formula <- NTL ~ lowSpeedDensity + temp +  NDVI + prevalance + emergence
points_mesh.in.Tokyo <- points_mesh.in.GT@data
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")

dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)

cor(dataset_used.Tokyo %>% dplyr::select(all.vars(formula)))

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
                         kernel = "bisquare",doParallel = T, cluster.number = 14, gradientIncrecement = T,
                         GI.step = 0.05, GI.upper = 1.5, GI.lower = 0.05)
#GWPR.FEM.bandwidth.step.list <- rbind(GWPR.FEM.bandwidth.step.list, GWPR.FEM.bandwidth)
GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
plot(GWPR.FEM.bandwidth.step.list[,1], GWPR.FEM.bandwidth.step.list[,2])
save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.Stage2NTL.145.005.005.Rdata")

GWPR.FEM.bandwidth = 1.20 ###
################################ this is GWPR based on FEM
points_mesh.in.Tokyo@data <- points_mesh.in.Tokyo@data %>% rename("id"="GridID")
points_mesh.in.Tokyo@data <- points_mesh.in.Tokyo@data %>% dplyr::select(id)
GWPR.FEM.CV.F.result.NTL <- GWPR(formula = formula, data = dataset_used.Tokyo%>%rename("id"="GridID"), index = c("id", "time"),
                             SDF = points_mesh.in.Tokyo, bw = GWPR.FEM.bandwidth, adaptive = F,
                             p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                             model = "within")

GWPR.FEM.CV.F.result.NTL$SDF@data %>% View()
summary(GWPR.FEM.CV.F.result.NTL$SDF@data$lowSpeedDensity_TVa %>% as.numeric())
save(GWPR.FEM.CV.F.result.NTL, file = "03_Results/GWPR_FEM_CV_F_result_NTL_1.20.Rdata")
