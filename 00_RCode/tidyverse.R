library(tidyverse)
library(dplyr)
library(rgdal)
library(sp)
library(GISTools)
library(rgeos)
library(sf)
library(raster)

CleanData <- function(raw_data){
  names(raw_data) <- c("Ori_ID", "Des_ID", "Year", "Month", "Workday", "Hour",
                         "Speed", "Sample", "Sample_estimation", "Real", 
                         "Real_estimation")
  raw_data <- raw_data %>% dplyr::select(-Year, -Month, -Workday, -Hour,
                                         -Sample, -Sample_estimation)
  raw_data <- raw_data %>% 
    mutate(Speed = ifelse(Speed == "60km/h以上", "60+", Speed),
           Speed = ifelse(Speed == "20km/h以上60km/h未満", "20-60", Speed),
           Speed = ifelse(Speed == "20km/h未満", "20-", Speed),
           Speed = ifelse(Speed == "NA合算", NA, Speed))
  raw_data <- raw_data %>%
    mutate(Speed = ifelse(is.na(Speed), "20-", Speed),
           Real = ifelse(is.na(Real), 1, Real),
           Real_estimation = ifelse(is.na(Real_estimation), 1, Real_estimation)) 
  raw_data$Speed <- raw_data$Speed %>% as.factor()
  return(raw_data)
}

AggragateData <- function(raw_data, speed_set, valid_ID){
  raw_data <- raw_data %>%
    dplyr::select(Ori_ID, Des_ID, Speed, Real_estimation) %>%
    filter(Speed == speed_set) %>%
    dplyr::select(Ori_ID, Des_ID, Real_estimation) %>%
    filter((Ori_ID %in% valid_ID)) %>%
    filter((Des_ID %in% valid_ID))
  
  raw_data <- raw_data %>%
    aggregate(by = list(raw_data$Ori_ID, raw_data$Des_ID), FUN = sum)
  raw_data <- raw_data %>%
    dplyr::select(-Ori_ID, -Des_ID) %>%
    rename(Ori_ID = Group.1,
           Des_ID = Group.2)
  raw_data <- raw_data %>%
    filter(!(Ori_ID == Des_ID))
  return(raw_data)
}

MonthSpeedOutput <- function(data.frame.input, point.coords, loop = c(0,1,2,3), half = 0, fileaddress){
  message("Begin!\n")
  quarter <- round(nrow(data.frame.input)/4)
  message(quarter)
  lower <- quarter*loop + 1
  if(loop == 3){
    upper <- nrow(data.frame.input)
  } else {
    upper <- quarter * (loop + 1)
  }
  if(half == 1){
    upper <- upper - round(quarter/2)
  } 
  if(half == 2){
    lower <- round(quarter/2) + lower
  }
  message(upper, "-", lower)
  data.frame.input <- data.frame.input[lower:upper,]
  Ori <- data.frame.input %>%
    dplyr::select(Ori_ID)
  Ori <- left_join(Ori, point.coords %>% rename(Ori_ID = ID), by = "Ori_ID")
  Des <- data.frame.input %>%
    dplyr::select(Des_ID)
  Des <- left_join(Des, point.coords %>% rename(Des_ID = ID), by = "Des_ID")
  coordinates(Ori) <- ~X+Y
  proj4string(Ori) <- proj
  Ori <- st_as_sf(Ori)
  coordinates(Des) <- ~X+Y
  proj4string(Des) <- proj
  Des <- st_as_sf(Des)
  Des <- Des %>%
    rename(geometry.1 = geometry)
  Cbind_Ori_Des <- cbind(Ori, Des)
  rm(Ori)
  rm(Des)
  gc()
  cat("Table done! Line processing!\n")
  Cbind_Ori_Des <- Cbind_Ori_Des %>%
    filter(!(Ori_ID == Des_ID))
  lines.total <- st_sfc(mapply(function(a,b){st_cast(st_union(a,b),"LINESTRING")},
                                   Cbind_Ori_Des$geometry, Cbind_Ori_Des$geometry.1,
                                   SIMPLIFY=FALSE))
  message("Raw line done!")
  rm(Cbind_Ori_Des)
  gc()
  lines.total <- st_as_sf(lines.total)
  lines.total$Real_estimation <- data.frame.input[,3]
  lines.total.used <- lines.total
  rm(lines.total)
  rm(data.frame.input)
  rm(point.coords)
  gc()
  message("Used line done!")
  st_crs(lines.total.used) <- "+proj=longlat +datum=WGS84 +no_defs"
  mesh_grid <- readOGR(dsn = ".", layer = "MeshFile")
  mesh_grid@data <- mesh_grid@data %>%
    dplyr::select(G04d_001)
  mesh_grid <- st_as_sf(mesh_grid)
  message("Spatial join the mesh and line!")
  output_data_frame <- data.frame(Doubles = double(),
                                  Character = character())
  cursor <- 1
  n <- nrow(mesh_grid)
  while (cursor < (n/10000 + 1)){
    mesh_grid_1 <- mesh_grid[1:10000,]
    mesh_grid <- mesh_grid[10001:nrow(mesh_grid),]
    test <- st_join(mesh_grid_1, lines.total.used)
    test <- as.data.frame(test)
    test <- test %>%
      dplyr::select(-geometry)
    test <- test$Real_estimation %>%
      aggregate(by = list(test$G04d_001), FUN = sum)
    output_data_frame <- rbind(output_data_frame, test)
    cursor <- cursor + 1
  }
  write.csv(output_data_frame, file = fileaddress)
  cat("Done!\n")
}


setwd("C:\\11_Article\\01_Data\\01_mesh\\")
mesh_grid <- readOGR(dsn = ".", layer = "MeshFile")
proj <- mesh_grid@proj4string
class(mesh_grid)

cents <- gCentroid(mesh_grid, byid = T)
cents$ID <- mesh_grid@data$G04d_001
rm(mesh_grid)

cents <- st_as_sf(cents)
cents$ID <- cents$ID %>% as.numeric()
valid_ID <- cents$ID
cents.coords <- st_coordinates(cents)
cents.coords <- cbind(cents, cents.coords)
cents.coords <- st_drop_geometry(cents.coords)
rm(cents)
gc()
#write.csv(cents.coords, file = "C:\\11_Article\\01_Data\\02_ODMatrix\\coords.csv")

setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
have.flag <- T
if(have.flag){
  raw_data_2019_01 <- read.csv("C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_01.csv")
} else {
  raw_data_2019_01 <- read_csv("od_data_201901.csv", 
                               locale = locale(encoding = "shift-jis"))
  raw_data_2019_01 <- CleanData(raw_data_2019_01)
  write.csv(raw_data_2019_01, file = "C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_01.csv")
}
raw_data_2019_01.20_ <- AggragateData(raw_data_2019_01, "20-", cents$ID)
rm(cents)
gc()
setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_01.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_01.20_.q1.csv")
MonthSpeedOutput(raw_data_2019_01.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_01.20_.q2.csv")
MonthSpeedOutput(raw_data_2019_01.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_01.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_01.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_01.20_.q4.csv")
#low speed only 20-, while 20-60, 60+


# 2020.02 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
have.flag <- F
if(have.flag){
  raw_data_2019_02 <- read.csv("C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_02.csv")
} else {
  raw_data_2019_02 <- read_csv("od_data_201902.csv", 
                               locale = locale(encoding = "shift-jis"))
  raw_data_2019_02 <- CleanData(raw_data_2019_02)
  write.csv(raw_data_2019_02, file = "C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_021.csv")
}
raw_data_2019_02.20_ <- AggragateData(raw_data_2019_02, "20-", valid_ID)
rm(raw_data_2019_02)
gc()
setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_02.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_02.20_.q1.csv")
MonthSpeedOutput(raw_data_2019_02.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_02.20_.q2.csv")
MonthSpeedOutput(raw_data_2019_02.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_02.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_02.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_02.20_.q4.csv")

# 2020.03 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
have.flag <- F
if(have.flag){
  raw_data_2019_03 <- read.csv("C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_03.csv")
} else {
  raw_data_2019_03 <- read_csv("od_data_201903.csv", 
                               locale = locale(encoding = "shift-jis"))
  raw_data_2019_03 <- CleanData(raw_data_2019_03)
  write.csv(raw_data_2019_03, file = "C:\\11_Article\\01_Data\\02_ODMatrix\\raw_data_2019_03.csv")
}
raw_data_2019_03.20_ <- AggragateData(raw_data_2019_03, "20-", valid_ID)
rm(raw_data_2019_03)
gc()
save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp.Rdata")

setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_03.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_03.20_.q1.csv")
MonthSpeedOutput(raw_data_2019_03.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_03.20_.q2.csv")
MonthSpeedOutput(raw_data_2019_03.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_03.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_03.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_03.20_.q4.csv")


# 2020.04 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
raw_data_2019_04 <- read_csv("od_data_201904.csv", 
                               locale = locale(encoding = "shift-jis"))
raw_data_2019_04 <- CleanData(raw_data_2019_04)

raw_data_2019_04.20_ <- AggragateData(raw_data_2019_04, "20-", valid_ID)
rm(raw_data_2019_04)
gc()
save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp.Rdata")

setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_04.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_04.20_.q1.csv")
MonthSpeedOutput(raw_data_2019_04.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_04.20_.q2.csv")
MonthSpeedOutput(raw_data_2019_04.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_04.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_04.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_04.20_.q4.csv")

# 2020.05 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
raw_data_2019_05 <- read_csv("od_data_201905.csv", 
                             locale = locale(encoding = "shift-jis"))
raw_data_2019_05 <- CleanData(raw_data_2019_05)

raw_data_2019_05.20_ <- AggragateData(raw_data_2019_05, "20-", valid_ID)
rm(raw_data_2019_05)
gc()
#save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp.Rdata")

load("C:/11_Article/01_Data/02_ODMatrix/Temp.Rdata")
setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_05.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_05.20_.q1.csv")
MonthSpeedOutput(raw_data_2019_05.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_05.20_.q2.csv") 
MonthSpeedOutput(raw_data_2019_05.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_05.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_05.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_05.20_.q4.csv")


# 2020.06 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
raw_data_2019_06 <- read_csv("od_data_201906.csv", 
                             locale = locale(encoding = "shift-jis"))
raw_data_2019_06 <- CleanData(raw_data_2019_06)

raw_data_2019_06.20_ <- AggragateData(raw_data_2019_06, "20-", valid_ID)
rm(raw_data_2019_06)
gc()
#save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp.Rdata")

load("C:/11_Article/01_Data/02_ODMatrix/Temp.Rdata")
setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_06.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_06.20_.q1.csv") 
MonthSpeedOutput(raw_data_2019_06.20_, cents.coords, loop = 1, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_06.20_.q2.csv") 
MonthSpeedOutput(raw_data_2019_06.20_, cents.coords, loop = 2, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_06.20_.q3.csv")
MonthSpeedOutput(raw_data_2019_06.20_, cents.coords, loop = 3, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_06.20_.q4.csv") 

# 2020.07 20-
setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
### be carefully here, we have write a csv, we do not need to do it again
raw_data_2019_07 <- read_csv("od_data_201907.csv", 
                             locale = locale(encoding = "shift-jis"))
raw_data_2019_07 <- CleanData(raw_data_2019_07)

raw_data_2019_07.20_ <- AggragateData(raw_data_2019_07, "20-", valid_ID)
rm(raw_data_2019_07)
gc()
rm(raw_data_2019_06.20_)
#save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp.Rdata")

load("C:/11_Article/01_Data/02_ODMatrix/Temp.Rdata")
setwd("C:\\11_Article\\01_Data\\01_mesh\\")
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 0, 
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q1.csv") 
# from here a new version of MonthSpeedOutput begin to be used
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 1, half = 1,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q2.1.csv")
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 1, half = 2,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q2.2.csv") 
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 2, half = 1,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q3.1.csv")
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 2, half = 2,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q3.2.csv") #
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 3, half = 1,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q4.1.csv") 
MonthSpeedOutput(raw_data_2019_07.20_, cents.coords, loop = 3, half = 2,
                 fileaddress = "C:/11_Article/01_Data/04_WashedData/raw_data_2019_07.20_.q4.2.csv") 
