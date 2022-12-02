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

formula <- lowSpeedDensity ~ NTL + NDVI + Temperature + prevalance + emergence

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
                         kernel = "bisquare",doParallel = T, cluster.number = 10, gradientIncrecement = T,
                         GI.step = 0.0025, GI.upper = 0.2, GI.lower = 0.0025)
#test 0.005 step length, from 0.015 degree
#GWPR.FEM.bandwidth.step.list <- rbind(GWPR.FEM.bandwidth.step.list, GWPR.FEM.bandwidth)
GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
plot(GWPR.FEM.bandwidth.step.list[,1], GWPR.FEM.bandwidth.step.list[,2])
save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.0200.00025.00025.Rdata")

GWPR.FEM.bandwidth = 0.015 ###
################################ this is GWPR based on FEM
points_mesh.in.Tokyo@data <- points_mesh.in.Tokyo@data %>% dplyr::select(GridID)
GWPR.FEM.CV.F.result <- GWPR(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                             SDF = points_mesh.in.Tokyo, bw = GWPR.FEM.bandwidth, adaptive = F,
                             p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                             model = "within")

GWPR.FEM.CV.F.result$SDF@data %>% View()
summary(GWPR.FEM.CV.F.result$SDF@data$NTL_TVa %>% as.numeric())
save(GWPR.FEM.CV.F.result, file = "03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")

load("03_Results/GWPR_BW_setp_list.Tokyo.0200.0015.0005.Rdata")
load("03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")

GWPR.FEM.CV.F.result$SDF$NTL <- GWPR.FEM.CV.F.result$SDF$NTL %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$NDVI <- GWPR.FEM.CV.F.result$SDF$NDVI %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$Temperature <- GWPR.FEM.CV.F.result$SDF$Temperature %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$prevalance <- GWPR.FEM.CV.F.result$SDF$prevalance %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$emergence <- GWPR.FEM.CV.F.result$SDF$emergence %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$NTL_TVa <- GWPR.FEM.CV.F.result$SDF$NTL_TVa %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$NDVI_TVa <- GWPR.FEM.CV.F.result$SDF$NDVI_TVa %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$Temperature_TVa <- GWPR.FEM.CV.F.result$SDF$Temperature_TVa %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$prevalance_TVa <- GWPR.FEM.CV.F.result$SDF$prevalance_TVa %>% as.numeric()
GWPR.FEM.CV.F.result$SDF$emergence_TVa <- GWPR.FEM.CV.F.result$SDF$emergence_TVa %>% as.numeric()

hist(GWPR.FEM.CV.F.result$SDF$NTL_TVa)
hist(GWPR.FEM.CV.F.result$SDF$NDVI_TVa)
hist(GWPR.FEM.CV.F.result$SDF$NTL)

### Moran I test
pdata <- pdata.frame(dataset_used.Tokyo , index = c("GridID", "time"))
fem <- plm(formula, pdata, model = "within")
summary(fem)
moran.test.result <- GWPR.moran.test(fem, SDF = points_mesh.in.Tokyo, bw = GWPR.FEM.bandwidth)
moran.test.result

GWPR.FEM.bandwidth.temp <-
  c(169335520, 246166362, 54478341, 106825361, 170485959, 52470546, 98328164, 119094439, # 0.02
    68031382, 96273843, 70460731, 76411967, 82523261, 68907767, 79838406, 83369647, # 0.04
    78814983, 83069440, 94671040, 92346531, 93639655, 97400574, 96500364, 105328915, # 0.06
    103172993, 108376984, 108376984, 116806274, 122287170, 128032493, 128669532, 135547573, # 0.08
    133396281, 138741250, 147216220, 143733511, 146815411, 152955409, 151361974, 157777848, # 0.10
    154885725, 161805554, 163301140, 164404284, 168440166, 173955825, 175735641, 179891492, # 0.12
    184164716, 189121961, 192260140, 195698420, 199618679, 205245167, 207852793, 210596774, # 0.14
    215415933, 216794229, 220253753, 223309878, 225327396, 228726201, 228819643, 231412879, # 0.16
    235055216, 235682452, 237982507, 240489300, 241485007, 243588578, 242300083, 24238402, # 0.18
    241220978, 238628371, 238322413, 235883249, 233084975, 230788726, 231062511, # 0.1975
  )