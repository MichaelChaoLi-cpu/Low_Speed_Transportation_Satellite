# Author: M.L.

# end

library(tidyverse)
library(dplyr)
library(rgdal)
library(stringr)
library(rgeos)
library(raster)
library(plm)

extractPointDataFromRaster <- function(RasterFolder, filelist, cityLocationSpatialPoint,
                                       year_start_location, month_start_location, flip_reverse = T,
                                       aimed_column_name = "raw", year_end_location = year_start_location + 3,
                                       month_end_location = month_start_location + 1
){
  RasterDataset <- 
    data.frame(Doubles=double(),
               Ints=integer(),
               Factors=factor(),
               Logicals=logical(),
               Characters=character(),
               stringsAsFactors=FALSE)
  for (filename in filelist){
    test_tiff <- raster::raster(paste0(RasterFolder, filename))
    if(flip_reverse){
      test_tiff <- flip(test_tiff, direction = 'y')
    }
    crs(test_tiff) <- proj
    Year <- str_sub(filename, year_start_location, year_end_location) %>% as.numeric()
    Month <- str_sub(filename, month_start_location, month_end_location) %>% as.numeric()
    
    data_ext <- raster::extract(test_tiff, cityLocationSpatialPoint)
    cityLocationSpatialPoint@data$raw <- data_ext
    monthly_data <- cityLocationSpatialPoint@data %>%
      dplyr::select(GridID, raw)
    monthly_data <- monthly_data %>%
      mutate(year = Year,
             month = Month)
    RasterDataset <- rbind(RasterDataset, monthly_data)
  }
  colnames(RasterDataset) <- c("GridID", aimed_column_name, "year", "month")
  return(RasterDataset)
}

setwd("D:\\11_Article\\01_Data\\01_mesh\\")
mesh_grid <- readOGR(dsn = ".", layer = "MeshFile")
mesh_grid@data <- mesh_grid@data %>%
  dplyr::select(G04d_001)
colnames(mesh_grid@data) <- c("GridID")
mesh_grid.ori <- mesh_grid

# here is to test the raster
centroids_mesh <- gCentroid(mesh_grid.ori, byid = T, id = mesh_grid$GridID)
points_mesh <- coordinates(centroids_mesh) %>% as.data.frame()
points_mesh <- cbind(points_mesh, mesh_grid.ori@data)
xy <- points_mesh[,c(1,2)]
proj <- mesh_grid@proj4string
points_mesh <- SpatialPointsDataFrame(coords = xy, data = points_mesh,
                                      proj4string = proj)
#get ndvi
NDVIRasterFolder <- "D:\\11_Article\\01_Data\\03_NDVI\\VI_16Days_250m_v6\\NDVI\\"
filelist <- list.files(NDVIRasterFolder)
NDVIRasterDataset <- 
  extractPointDataFromRaster(NDVIRasterFolder, filelist, points_mesh,
                             14, 19, F, "NDVI", 17, 21)
save(NDVIRasterDataset, file = "04_Data/06_NDVIRasterDataset.RData")

#get day temperature
dayTempRasterFolder <- "D:\\11_Article\\01_Data\\06_Tempature\\Surf_Temp_Monthly_005dg_v6\\LST_Day_CMG\\"
filelist <- list.files(dayTempRasterFolder)
dayTempRasterDataset <- 
  extractPointDataFromRaster(dayTempRasterFolder, filelist, points_mesh,
                             21, month_start_location = 26, F,
                             "dayTimeTemperature", month_end_location = 28)
dayTempRasterDataset.ag <- aggregate(dayTempRasterDataset$dayTimeTemperature,
                                     by = list(dayTempRasterDataset$GridID, dayTempRasterDataset$year,
                                               dayTempRasterDataset$month), FUN = mean, na.rm = T) 
colnames(dayTempRasterDataset.ag) <- c("GridID", "year", "month", "dayTimeTemperature")
save(dayTempRasterDataset.ag, file = "04_Data/03_dayTempRasterDataset.ag.RData")

#get monthly Nighttime temperature from the MOD11C3 0.25 arc degree
nightTimeTemperatureRasterFolder <- "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Monthly_005dg_v6/LST_Night_CMG/"
filelist <- list.files(nightTimeTemperatureRasterFolder)
nightTimeTemperatureRasterDataset <- 
  extractPointDataFromRaster(nightTimeTemperatureRasterFolder, filelist, points_mesh,
                             23, month_start_location = 28, F,
                             "nightTimeTemperature", month_end_location = 30)
nightTimeTemperatureRasterDataset.ag <- aggregate(nightTimeTemperatureRasterDataset$dayTimeTemperature,
                                     by = list(nightTimeTemperatureRasterDataset$GridID, 
                                               nightTimeTemperatureRasterDataset$year,
                                               nightTimeTemperatureRasterDataset$month), FUN = mean, na.rm = T) 
colnames(nightTimeTemperatureRasterDataset.ag) <- c("GridID", "year", "month", "dayTimeTemperature")
save(nightTimeTemperatureRasterDataset.ag, file = "04_Data/04_nightTimeTemperatureRasterDataset.ag.RData")

#Nighttime Light
NTLRasterFolder <- "D:/11_Article/01_Data/05_NTL/NTL_Raster/temp/"
filelist <- list.files(NTLRasterFolder)
NTLRasterDataset <- 
  extractPointDataFromRaster(NTLRasterFolder, filelist, points_mesh,
                             11, 15, F, "NTL")
save(NTLRasterDataset, file = "04_Data/05_NTLRasterDataset.RData")


load("04_Data/02_panelLowSpeedDensityDataset.RData")
dataset_used <- left_join(panelLowSpeedDensityDataset, dayTempRasterDataset.ag, 
                          by = c("GridID", "year", "month"))
dataset_used$time <- dataset_used$year * 100 + dataset_used$month

pdata <- pdata.frame(dataset_used, index = c("GridID", "time"))
formula <- lowSpeedDensity ~ dayTimeTemperature
ols <- plm(formula, pdata, model = "pooling")
summary(ols)
fem <- plm(formula, pdata, model = "within")
summary(fem)
rem <- plm(formula, pdata, model = "random")
summary(rem)
