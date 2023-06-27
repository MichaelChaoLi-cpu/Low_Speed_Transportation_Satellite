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


dataset_Xshap2 <- dataset_Xshap
#### XGBoost and Shap
dataset_Xshap2$tair2 <- dataset_Xshap2$tair * dataset_Xshap2$tair
formula <- tair_shap ~ tair + tair2
reg_tair <- lm(formula, dataset_Xshap2)
summary(reg_tair)

GWPR.result.tair <- GWPR(formula = tair_shap ~ tair, data = dataset_Xshap, index = c("GridID", "time"),
                         SDF = points_mesh, bw = 0.0075, adaptive = F,
                         p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                         model = "pooling")
tm_shape(GWPR.result.tair$SDF) +
  tm_dots(col = "tair", pal = rev("RdYlBu"),midpoint = 0,
          style = 'cont')








