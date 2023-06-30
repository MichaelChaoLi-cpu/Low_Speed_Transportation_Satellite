# Author: M.L.


#Note: we use "03_mergedXSHAPStdize_noah_withoutAP.csv"

# end

library(tidyverse)
library(dplyr)
library(GWPR.light)
library(plm)
library(sp)
library(tmap)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
dataset_Xshap <- read.csv('03_Results/03_mergedXSHAPStdize_noah_withoutAP.csv')

formula <- lowSpeedDensity ~ tair +  psurf + qair + wind + rainf +
  NTL + NDVI + PBLH + prevalance + 
  mortality + emergence  

reg <- lm(formula, dataset_Xshap)
summary(reg)

point_dataset <- dataset_Xshap[,c(1,10,11)] %>% distinct()
xy <- point_dataset[,c(2,3)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = point_dataset,
                                      proj4string = CRS(proj))
points_mesh@data <- points_mesh@data %>% dplyr::select(GridID)

GWPR.result <- GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
                    SDF = points_mesh, bw = 0.0075, adaptive = F,
                    p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                    model = "pooling")
tm_shape(GWPR.result$SDF) +
  tm_dots(col = "tair", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')


#### XGBoost and Shap
formula <- tair_shap ~ tair 
reg_tair <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_tair)

(moran.i.tair <- GWPR.moran.test(reg_tair, points_mesh, 0.0075))
saveRDS(moran.i.tair, '12_Results0618/03.moran.i.tair.rds')

GWPR.bw.tair <- # this is about fixed bandwidth
  bw.GWPR(formula = formula, data = dataset_Xshap, index = c("GridID", "time"),
          SDF = points_mesh, adaptive = F, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "pooling", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 8, gradientIncrement = T,
          GI.step = 0.0025, GI.upper = 0.041, GI.lower = 0.0025)
saveRDS(GWPR.bw.tair, '12_Results0618/01.GWPR.bw.tair.rds')

### tair
GWPR.result.tair <- GWPR(formula = tair_shap ~ tair, data = dataset_Xshap, index = c("GridID", "time"),
                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                         model = "pooling")
tm_shape(GWPR.result.tair$SDF) +
  tm_dots(col = "tair", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.tair, '12_Results0618/02.GWPR.result.tair.rds')

### psurf
formula <- psurf_shap ~ psurf
reg_psurf <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_psurf)

(moran.i.psurf <- GWPR.moran.test(reg_psurf, points_mesh, 0.0075))
saveRDS(moran.i.psurf, '12_Results0618/03.moran.i.psurf.rds')

GWPR.result.psurf <- GWPR(formula = psurf_shap ~ psurf, data = dataset_Xshap, index = c("GridID", "time"),
                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                         model = "pooling")
tm_shape(GWPR.result.psurf$SDF) +
  tm_dots(col = "psurf", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.psurf, '12_Results0618/02.GWPR.result.psurf.rds')

### qair
formula <- qair_shap ~ qair
reg_qair <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_qair)

(moran.i.qair <- GWPR.moran.test(reg_qair, points_mesh, 0.0075))
saveRDS(moran.i.qair, '12_Results0618/03.moran.i.qair.rds')

GWPR.result.qair <- GWPR(formula = qair_shap ~ qair, data = dataset_Xshap, index = c("GridID", "time"),
                          SDF = points_mesh, bw = 0.0075, adaptive = F,
                          p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                          model = "pooling")
tm_shape(GWPR.result.qair$SDF) +
  tm_dots(col = "qair", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.qair, '12_Results0618/02.GWPR.result.qair.rds')

### wind
formula <- wind_shap ~ wind
reg_wind <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_wind)

(moran.i.wind <- GWPR.moran.test(reg_wind, points_mesh, 0.0075))
saveRDS(moran.i.wind, '12_Results0618/03.moran.i.wind.rds')

GWPR.result.wind <- GWPR(formula = wind_shap ~ wind, data = dataset_Xshap, index = c("GridID", "time"),
                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                         model = "pooling")
tm_shape(GWPR.result.wind$SDF) +
  tm_dots(col = "wind", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.wind, '12_Results0618/02.GWPR.result.wind.rds')

### rainf
formula <- rainf_shap ~ rainf
reg_rainf <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_rainf)

(moran.i.rainf <- GWPR.moran.test(reg_rainf, points_mesh, 0.0075))
saveRDS(moran.i.rainf, '12_Results0618/03.moran.i.rainf.rds')

GWPR.result.rainf <- GWPR(formula = rainf_shap ~ rainf, data = dataset_Xshap, index = c("GridID", "time"),
                          SDF = points_mesh, bw = 0.0075, adaptive = F,
                          p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                          model = "pooling")
tm_shape(GWPR.result.rainf$SDF) +
  tm_dots(col = "rainf", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.rainf, '12_Results0618/02.GWPR.result.rainf.rds')

### NTL
formula <- NTL_shap ~ NTL
reg_NTL <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_NTL)

(moran.i.NTL <- GWPR.moran.test(reg_NTL, points_mesh, 0.0075))
saveRDS(moran.i.NTL, '12_Results0618/03.moran.i.NTL.rds')

GWPR.result.NTL <- GWPR(formula = NTL_shap ~ NTL, data = dataset_Xshap, index = c("GridID", "time"),
                          SDF = points_mesh, bw = 0.0075, adaptive = F,
                          p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                          model = "pooling")
tm_shape(GWPR.result.NTL$SDF) +
  tm_dots(col = "NTL", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.NTL, '12_Results0618/02.GWPR.result.NTL.rds')

### NDVI
formula <- NDVI_shap ~ NDVI
reg_NDVI <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_NDVI)

(moran.i.NDVI <- GWPR.moran.test(reg_NDVI, points_mesh, 0.0075))
saveRDS(moran.i.NDVI, '12_Results0618/03.moran.i.NDVI.rds')

GWPR.result.NDVI <- GWPR(formula = NDVI_shap ~ NDVI, data = dataset_Xshap, index = c("GridID", "time"),
                        SDF = points_mesh, bw = 0.0075, adaptive = F,
                        p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                        model = "pooling")
tm_shape(GWPR.result.NDVI$SDF) +
  tm_dots(col = "NDVI", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.NDVI, '12_Results0618/02.GWPR.result.NDVI.rds')

### PBLH
formula <- PBLH_shap ~ PBLH
reg_PBLH <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_PBLH)

(moran.i.PBLH <- GWPR.moran.test(reg_PBLH, points_mesh, 0.0075))
saveRDS(moran.i.PBLH, '12_Results0618/03.moran.i.PBLH.rds')

GWPR.result.PBLH <- GWPR(formula = PBLH_shap ~ PBLH, data = dataset_Xshap, index = c("GridID", "time"),
                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                         model = "pooling")
tm_shape(GWPR.result.PBLH$SDF) +
  tm_dots(col = "PBLH", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')
saveRDS(GWPR.result.PBLH, '12_Results0618/02.GWPR.result.PBLH.rds')

formula <- prevalance_shap ~ prevalance
reg_prevalance <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_prevalance)

formula <- mortality_shap ~ mortality
reg_mortality <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_mortality)

formula <- emergence_shap ~ emergence
reg_emergence <- plm(formula, dataset_Xshap, index = c('GridID', 'time'), model = 'pooling')
summary(reg_emergence)



