# Author: M.L.

# end

library(tidyverse)
library(dplyr)
library(rgdal)
library(stringr)
library(rgeos)
library(raster)
library(plm)
library(COVID19)
library(lubridate)
library(stringr)

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
rm(mesh_grid)
rm(mesh_grid.ori)

#get ndvi MXD13Q1
NDVIRasterFolder <- "D:/11_Article/01_Data/03_NDVI/VI_16Days_250m_v6/NDVI/"
filelist <- list.files(NDVIRasterFolder)
NDVIRasterDataset <- 
  extractPointDataFromRaster(NDVIRasterFolder, filelist, points_mesh,
                             14, 19, F, "NDVI", 17, 21)
colnames(NDVIRasterDataset) <- c("GridID", "NDVI", "year", "month")
NDVIRasterDataset$date <- 
  as.Date((NDVIRasterDataset$month - 1),
          origin = paste0(NDVIRasterDataset$year,"-01-01")) %>% as.character()
NDVIRasterDataset$month <- str_sub(NDVIRasterDataset$date, 6, 7) %>% as.numeric()
NDVIRasterDataset <- NDVIRasterDataset %>% dplyr::select(-date)
NDVIRasterDataset <- aggregate(NDVIRasterDataset$NDVI,
                               by = list(NDVIRasterDataset$GridID, 
                                         NDVIRasterDataset$year, 
                                         NDVIRasterDataset$month), 
                               FUN = "mean", na.rm = T
)
colnames(NDVIRasterDataset) <- c("GridID", "year", "month", "NDVI")
NDVIRasterDataset$NDVI <- NDVIRasterDataset$NDVI / 10000  #convert into from 1 to -1 
NDVIRasterDataset$NDVI <- NDVIRasterDataset$NDVI * 100 #convert into from 100% to -100% 
save(NDVIRasterDataset, file = "04_Data/06_NDVIRasterDataset.RData")

run <- F
if(run) {
  #get ndvi
  NDVIRasterFolder <- "D:\\11_Article\\01_Data\\03_NDVI\\VI_Monthly_005dg_v6\\NDVI_Ext\\"
  filelist <- list.files(NDVIRasterFolder)
  NDVIRasterDataset <- 
    extractPointDataFromRaster(NDVIRasterFolder, filelist, points_mesh,
                               14, 19, F, "NDVI", 17, 21)
  colnames(NDVIRasterDataset) <- c("GridID", "NDVI", "year", "month")
  NDVIRasterDataset$date <- 
    as.Date((NDVIRasterDataset$month - 1),
            origin = paste0(NDVIRasterDataset$year,"-01-01")) %>% as.character()
  NDVIRasterDataset$month <- str_sub(NDVIRasterDataset$date, 6, 7) %>% as.numeric()
  NDVIRasterDataset <- NDVIRasterDataset %>% dplyr::select(-date)
  NDVIRasterDataset <- aggregate(NDVIRasterDataset$NDVI,
                                 by = list(NDVIRasterDataset$GridID, 
                                           NDVIRasterDataset$year, 
                                           NDVIRasterDataset$month), 
                                 FUN = "mean", na.rm = T
  )
  colnames(NDVIRasterDataset) <- c("GridID", "year", "month", "NDVI")
  NDVIRasterDataset$NDVI <- NDVIRasterDataset$NDVI / 10000  #convert into from 1 to -1 
  NDVIRasterDataset$NDVI <- NDVIRasterDataset$NDVI * 100 #convert into from 100% to -100% 
  save(NDVIRasterDataset, file = "04_Data/06_NDVIRasterDataset.RData")
}

#get temperature
dayTempRasterFolder <- "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/MergedMODIS/"
filelist <- list.files(dayTempRasterFolder)
dayTempRasterDataset <- 
  extractPointDataFromRaster(dayTempRasterFolder, filelist, points_mesh,
                             6, month_start_location = 11, F,
                             "Temperature", month_end_location = 13)
dayTempRasterDataset.ag <- aggregate(dayTempRasterDataset$dayTimeTemperature,
                                     by = list(dayTempRasterDataset$GridID, dayTempRasterDataset$year,
                                               dayTempRasterDataset$month), FUN = mean, na.rm = T) 
colnames(dayTempRasterDataset.ag) <- c("GridID", "year", "month", "dayTimeTemperature")
dayTempRasterDataset.ag$date <- 
  as.Date((dayTempRasterDataset.ag$month - 1),
          origin = paste0(dayTempRasterDataset.ag$year,"-01-01")) %>% as.character()
dayTempRasterDataset.ag$month <- str_sub(dayTempRasterDataset.ag$date, 6, 7) %>% as.numeric()
dayTempRasterDataset.ag <- dayTempRasterDataset.ag %>% dplyr::select(-date)
dayTempRasterDataset.ag$dayTimeTemperature <- dayTempRasterDataset.ag$dayTimeTemperature *
  0.02 - 273.16
save(dayTempRasterDataset.ag, file = "04_Data/03_dayTempRasterDataset.ag.RData")

#get monthly Nighttime temperature from the MOD11C3 0.005 arc degree
nightTimeTemperatureRasterFolder <- "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Monthly_005dg_v6/LST_Night_CMG_Ext/"
filelist <- list.files(nightTimeTemperatureRasterFolder)
nightTimeTemperatureRasterDataset <- 
  extractPointDataFromRaster(nightTimeTemperatureRasterFolder, filelist, points_mesh,
                             23, month_start_location = 28, F,
                             "nightTimeTemperature", month_end_location = 30)
nightTimeTemperatureRasterDataset.ag <- aggregate(nightTimeTemperatureRasterDataset$nightTimeTemperature,
                                     by = list(nightTimeTemperatureRasterDataset$GridID, 
                                               nightTimeTemperatureRasterDataset$year,
                                               nightTimeTemperatureRasterDataset$month), FUN = mean, na.rm = T) 
colnames(nightTimeTemperatureRasterDataset.ag) <- c("GridID", "year", "month", "nightTimeTemperature")
nightTimeTemperatureRasterDataset.ag$date <- 
  as.Date((nightTimeTemperatureRasterDataset.ag$month - 1),
          origin = paste0(nightTimeTemperatureRasterDataset.ag$year,"-01-01")) %>% as.character()
nightTimeTemperatureRasterDataset.ag$month <- str_sub(nightTimeTemperatureRasterDataset.ag$date, 6, 7) %>% as.numeric()
nightTimeTemperatureRasterDataset.ag <- nightTimeTemperatureRasterDataset.ag %>% dplyr::select(-date)
nightTimeTemperatureRasterDataset.ag$nightTimeTemperature <- nightTimeTemperatureRasterDataset.ag$nightTimeTemperature *
  0.02 - 273.16  #convert into c degree temperature
save(nightTimeTemperatureRasterDataset.ag, file = "04_Data/04_nightTimeTemperatureRasterDataset.ag.RData")

#Nighttime Light
NTLRasterFolder <- "D:/11_Article/01_Data/05_NTL/NTL_Raster/temp/"
filelist <- list.files(NTLRasterFolder)
NTLRasterDataset <- 
  extractPointDataFromRaster(NTLRasterFolder, filelist, points_mesh,
                             11, 15, F, "NTL")
save(NTLRasterDataset, file = "04_Data/05_NTLRasterDataset.RData")

#get monthly terrain pressure from the OMNO2G, band 29 (terrain pressure)
terrainPressureRasterFolder <- "D:/10_Article/09_TempOutput/03_MonthlyTerrainPressureTif/"
filelist <- list.files(terrainPressureRasterFolder)
terrainPressureRasterDataset <- 
  extractPointDataFromRaster(terrainPressureRasterFolder, filelist, points_mesh,
                             21, 26, T, "ter_pressure")
save(terrainPressureRasterDataset, file = "04_Data/07_terrainPressureRasterDatasett.RData")

#get monthly water vapor from the GLDAS_NOAH025_M 0.25 arc degree 
# Point based
humidityRasterFolder <- "D:/10_Article/09_TempOutput/06_MonthlyVaporTif/Add025Outline/"
filelist <- list.files(humidityRasterFolder)
humidityRasterDataset <- 
  extractPointDataFromRaster(humidityRasterFolder, filelist, points_mesh,
                             21, 25, T, "humidity")

humidityRasterDataset$humidity <- humidityRasterDataset$humidity * 1000 #convert the unit into g/kg
humidityRasterDataset <- humidityRasterDataset %>% as.data.frame()
humidityRasterDataset <- humidityRasterDataset %>%
  filter(year > 2018) %>%
  filter(year < 2021)

save(humidityRasterDataset, file = "04_Data/08_humidityRasterDataset.RData")
# 1 g/kg means 1 gram water in the 1 kg air.

#get monthly precipitation from the GLDAS_NOAH025_M 0.25 arc degree
# Point Based
precipitationRasterFolder <- "D:/10_Article/09_TempOutput/07_MonthlyPrecipitationTif/Add025Outline/"
filelist <- list.files(precipitationRasterFolder)
precipitationRasterDataset <- 
  extractPointDataFromRaster(precipitationRasterFolder, filelist, points_mesh,
                             27, 31, T, "precipitation")
precipitationRasterDataset$precipitation <- precipitationRasterDataset$precipitation * 3600 
precipitationRasterDataset <- precipitationRasterDataset %>% as.data.frame()
precipitationRasterDataset <- precipitationRasterDataset %>%
  filter(year > 2018) %>%
  filter(year < 2021)
save(precipitationRasterDataset, file = "04_Data/09_precipitationRasterDataset.RData")
# now, the precipitation unit is kg/(m2 * h)  

#get monthly speed wind from the GLDAS_NOAH025_M 0.25 arc degree
# point based
speedWindRasterFolder <- "D:/10_Article/09_TempOutput/09_WindSpeed/Add025Outline/"
filelist <- list.files(speedWindRasterFolder)
speedWindRasterDataset <- 
  extractPointDataFromRaster(speedWindRasterFolder, filelist, points_mesh,
                             19, 23, T, "speedwind")
speedWindRasterDataset <- speedWindRasterDataset %>% as.data.frame()
speedWindRasterDataset <- speedWindRasterDataset %>%
  filter(year > 2018) %>%
  filter(year < 2021)
save(speedWindRasterDataset, file = "04_Data/10_speedWindRasterDataset.RData")
# now, the speed wind unit is m/s  

#get monthly troposphere no2 from the OMNO2G, band 9(troposphere no2)
troposphereNo2RasterFolder <- "D:/10_Article/09_TempOutput/02_MonthlyTroposphericNo2Tif/"
filelist <- list.files(troposphereNo2RasterFolder)
troposphereNo2RasterDataset <- 
  extractPointDataFromRaster(troposphereNo2RasterFolder, filelist, points_mesh,
                             21, 26, T, "raw_no2")
# convert molecular / cm2 to ug / m2
mol_g = 6.022140857 * 10^23  # mol
troposphereNo2RasterDataset$g_cm2 <- troposphereNo2RasterDataset$raw_no2 / mol_g * 46.0055 # convert mol to g
troposphereNo2RasterDataset$mg_m2_troposphere_no2 <- troposphereNo2RasterDataset$g_cm2 * 10000 * 1000 # conver /cm2 to /m2 and g to mg
troposphereNo2RasterDataset <- troposphereNo2RasterDataset %>% dplyr::select("GridID", "year", "month", "mg_m2_troposphere_no2")
troposphereNo2RasterDataset$Date <- as.Date(
  paste0(as.character(troposphereNo2RasterDataset$year),"-",as.character(troposphereNo2RasterDataset$month),"-01")
)
troposphereNo2RasterDataset <- troposphereNo2RasterDataset %>%
  dplyr::select(-Date)
troposphereNo2RasterDataset <- troposphereNo2RasterDataset %>%
  filter(year > 2018) %>%
  filter(year < 2021)
save(troposphereNo2RasterDataset, file = "04_Data/11_troposphereNo2RasterDataset.RData")

# get monthly Ozone, 0.25 * 0.25
ozoneRasterLayer <- "D:/10_Article/09_TempOutput/14_MonthlyOzone/"
filelist <- list.files(ozoneRasterLayer)
filelist <- filelist[49:72]
ozoneRasterDataset <- 
  extractPointDataFromRaster(ozoneRasterLayer, filelist, points_mesh,
                             21, 26, T, "ozone")
save(ozoneRasterDataset, file = "04_Data/12_TotalOzoneDURasterDataset.RData")

# get monthly UV Aerosol Index, 0.25 * 0.25
UVAerosolIndexRasterLayer <- "D:/10_Article/09_TempOutput/15_MonthlyUVAerosolIndex/"
filelist <- list.files(UVAerosolIndexRasterLayer)
filelist <- filelist[49:72]
UVAerosolIndexRasterDataset <- 
  extractPointDataFromRaster(UVAerosolIndexRasterLayer, filelist, points_mesh,
                             21, 26, T, "UVAerosolIndex")
save(UVAerosolIndexRasterDataset, file = "04_Data/13_UVAerosolIndexRasterDataset.RData")
# get monthly UV Aerosol Index, 0.25 * 0.25

#get monthly planetary boundary layer height, 0.25 * 0.25 
PBLHRasterLayer <- "D:/10_Article/09_TempOutput/10_PlanetaryBoundaryLayerHeight/Resample/"
filelist <- list.files(PBLHRasterLayer)
filelist <- filelist[49:72]
PBLHRasterDataset <- 
  extractPointDataFromRaster(PBLHRasterLayer, filelist, points_mesh,
                             1, 5, F, "PBLH")
save(PBLHRasterDataset, file = "04_Data/14_PBLHRasterDataset.RData")
#get monthly planetary boundary layer height, 0.25 * 0.25 

setwd("D:/09_Article/02_Shapefile/N03-20210101_GML")
GT_map <- readOGR(dsn = ".", layer = "GreatTokyo")
GT_map <- spTransform(GT_map, proj)
setwd("C:/Users/li.chao.987@s.kyushu-u.ac.jp/OneDrive - Kyushu University/11_Article/03_RStudio/")

GT_map@data$PrefID <- str_sub(GT_map@data$N03_007, 1, 2) 

GT_map@data <- GT_map@data %>% dplyr::select("PrefID") 
GT.in.grid <- over(points_mesh, GT_map)

points_mesh.in.GT <- cbind(points_mesh@data, GT.in.grid)
points_mesh.in.GT <- points_mesh.in.GT %>% filter(!is.na(PrefID))
xy <- points_mesh.in.GT[,c(1,2)]
points_mesh.in.GT <- SpatialPointsDataFrame(coords = xy, data = points_mesh.in.GT,
                                      proj4string = proj)

save(points_mesh, file = "04_Data/00_points_mesh.RData")
save(points_mesh.in.GT, file = "04_Data/00_points_mesh.in.GT.RData")

deat.conf.pop <- COVID19::covid19(country = "JP", level = 2)

test <- deat.conf.pop %>% 
  dplyr::select("id", "date", "confirmed", "deaths") %>%
  as.data.frame()
test <- plm::pdata.frame(test, index = c("id", "date"))
test$confirmed.dif <- test$confirmed - plm::lag(test$confirmed)
test$deaths.dif <- test$deaths - plm::lag(test$deaths)
test <- test %>% 
  mutate(confirmed.dif = ifelse(confirmed.dif < 0, 0, confirmed.dif),
         deaths.dif = ifelse(deaths.dif < 0, 0, deaths.dif)) %>% 
  dplyr::select(-"confirmed", -"deaths")
test <- lapply(test, function(x){attr(x, c("id", "date")) <- NULL; x}) %>% as.data.frame()
test$id <- test$id %>% as.character()
test$date <- test$date %>% as.character() %>% ymd()

deat.conf.pop <- left_join(deat.conf.pop, test, by = c("id", "date"))
rm(test)

sub.Dataset.M <- function(dataset, input_date){
  dataset.id <- dataset %>% filter(date == ymd("2021-08-01")) %>%
    dplyr::select(id, population)
  input_date <- ymd(input_date)
  base_month = input_date %m-% months(1)
  dataset.output <- dataset %>% 
    dplyr::select(id, date, population, confirmed.dif, deaths.dif) %>%
    filter(ymd(date) < input_date,
           ymd(date) >= base_month) %>%
    as.data.frame()
  dataset.output <- dataset.output %>% 
    group_by(id) %>% 
    summarise(confirmed = sum(confirmed.dif, na.rm = T),
              deaths = sum(deaths.dif, na.rm = T))
  dataset.output <- left_join(dataset.id, dataset.output, by = "id")
  dataset.output <- dataset.output %>% 
    mutate(
      confirmed = ifelse(is.na(confirmed), 0, confirmed),
      deaths = ifelse(is.na(deaths), 0, deaths)
    )
  stringency <- dataset %>% filter(date > ymd(base_month)) %>%
    filter(date < ymd(input_date)) %>%
    dplyr::select(id, stringency_index)
  stringency <- stringency$stringency_index %>% 
    aggregate(by = list(stringency$id), mean)
  stringency <- stringency %>% rename(id = Group.1)
  dataset.output <- left_join(dataset.output, stringency, by = "id") 
  dataset.output$date <- ymd(base_month)
  colnames(dataset.output) <- c("id", "population", "confirmed", "deaths", 
                                "stringency_index", "date")
  dataset.output <- dataset.output %>% 
    mutate(
      stringency_index = ifelse(is.na(stringency_index), 0, stringency_index)
    )
  return(dataset.output)
}

deat.conf.pop.202001 <- sub.Dataset.M(deat.conf.pop, "2020-02-01")
deat.conf.pop.202002 <- sub.Dataset.M(deat.conf.pop, "2020-03-01")
deat.conf.pop.202003 <- sub.Dataset.M(deat.conf.pop, "2020-04-01")
deat.conf.pop.202004 <- sub.Dataset.M(deat.conf.pop, "2020-05-01")
deat.conf.pop.202005 <- sub.Dataset.M(deat.conf.pop, "2020-06-01")
deat.conf.pop.202006 <- sub.Dataset.M(deat.conf.pop, "2020-07-01")
deat.conf.pop.202007 <- sub.Dataset.M(deat.conf.pop, "2020-08-01")
deat.conf.pop.202008 <- sub.Dataset.M(deat.conf.pop, "2020-09-01")
deat.conf.pop.202009 <- sub.Dataset.M(deat.conf.pop, "2020-10-01")
deat.conf.pop.202010 <- sub.Dataset.M(deat.conf.pop, "2020-11-01")
deat.conf.pop.202011 <- sub.Dataset.M(deat.conf.pop, "2020-12-01")
deat.conf.pop.202012 <- sub.Dataset.M(deat.conf.pop, "2021-01-01")

merge_df.M <- rbind(
  deat.conf.pop.202001, deat.conf.pop.202002,
  deat.conf.pop.202003, deat.conf.pop.202004, deat.conf.pop.202005,
  deat.conf.pop.202006, deat.conf.pop.202007, deat.conf.pop.202008,
  deat.conf.pop.202009, deat.conf.pop.202010, deat.conf.pop.202011,
  deat.conf.pop.202012
)
rm(
  deat.conf.pop.202001, deat.conf.pop.202002,
  deat.conf.pop.202003, deat.conf.pop.202004, deat.conf.pop.202005,
  deat.conf.pop.202006, deat.conf.pop.202007, deat.conf.pop.202008,
  deat.conf.pop.202009, deat.conf.pop.202010, deat.conf.pop.202011,
  deat.conf.pop.202012
)
dataset.id <- deat.conf.pop %>% filter(date == ymd("2021-08-01"))
dataset.id <- dataset.id %>% dplyr::select(id, key_local) %>% as.data.frame()
merge_df.M <- left_join(merge_df.M, dataset.id)
merge_df.M <- merge_df.M %>% rename(PrefID = key_local)
rm(dataset.id)

merge_df.M$prevalance <- merge_df.M$confirmed / merge_df.M$population * 100
merge_df.M$mortality <- merge_df.M$deaths / merge_df.M$population * 100

setwd("D:/09_Article/02_Shapefile/N03-20210101_GML")
GT_map <- readOGR(dsn = ".", layer = "GreatTokyo")
GT_map <- spTransform(GT_map, proj)
setwd("C:/Users/li.chao.987@s.kyushu-u.ac.jp/OneDrive - Kyushu University/11_Article/03_RStudio/")

load("04_Data/00_points_mesh.in.GT.RData")
GT_map@data$PrefID <- str_sub(GT_map@data$N03_007, 1, 2) 

GT_map@data <- GT_map@data %>% dplyr::select("PrefID") 

month.vector <- merge_df.M$date %>% unique()
dataset.output <-  data.frame(Date=as.Date(character()),
                              File=character(), 
                              User=character(), 
                              stringsAsFactors=FALSE) 
loop = 1
while (loop < (length(month.vector) + 1) ){
  aimed.month <- month.vector[loop]
  GT_map.month <- GT_map
  GT_map.month@data <- left_join(GT_map.month@data, merge_df.M %>% filter(date == ymd(aimed.month))) %>%
    dplyr::select(prevalance, mortality)
  
  covid19.grid <- over(points_mesh.in.GT, GT_map.month)
  covid19.grid <- cbind(points_mesh.in.GT@data, covid19.grid)
  covid19.grid <- covid19.grid %>% dplyr::select(GridID, prevalance, mortality)
  covid19.grid$year <- str_sub(aimed.month, 1, 4) %>% as.numeric()
  covid19.grid$month <- str_sub(aimed.month, 6, 7) %>% as.numeric()
  dataset.output <- rbind(dataset.output, covid19.grid)
  loop = loop + 1
}

covid19PrefectureData <- dataset.output 
covid19PrefectureData$emergence <- 0 
covid19PrefectureData <- covid19PrefectureData %>%
  mutate(emergence = ifelse(month == 4, 0.8333, emergence),
         emergence = ifelse(month == 5, 0.6774, emergence))
save(covid19PrefectureData, file = "04_Data/15_covid19PrefectureData.RData")
