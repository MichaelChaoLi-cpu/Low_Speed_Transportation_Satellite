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

MonthSpeedOutput <- function(data.frame.input, point.coords, loop = 0, fileaddress){
  message("Begin!\n")
  quarter <- round(nrow(data.frame.input)/8)
  message(quarter)
  lower <- quarter*loop + 1
  if(loop == 7){
    upper <- nrow(data.frame.input)
  } else {
    upper <- quarter * (loop + 1)
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

AggregatedFunction <- function(year, month, valid_ID, cents.coords){
  setwd("C:\\11_Article\\01_Data\\02_ODMatrix\\")
  raw_data <- read_csv(paste0("od_data_",year,month,".csv"), 
                               locale = locale(encoding = "shift-jis"))
  message("Read Raw Data Done!")
  raw_data <- CleanData(raw_data)
  message("Clean Raw Data Done!")
  
  raw_data.20_ <- AggragateData(raw_data, "20-", valid_ID)
  message("AggregateD Data Done")
  rm(raw_data)
  gc()
  loop = 0
  while(loop < 8){
    setwd("C:\\11_Article\\01_Data\\01_mesh\\")
    MonthSpeedOutput(raw_data.20_, cents.coords, loop = loop, 
                     fileaddress = 
                       paste0("C:/11_Article/01_Data/04_WashedData/raw_data_",
                              year,"_", month,
                              ".20_.q", as.character(loop), ".csv"))
    message("loop: ", loop)
    loop = loop + 1
  }
}
save.image("C:\\11_Article\\01_Data\\02_ODMatrix\\Temp2.Rdata")

AggregatedFunction(year = "2019", month = "08",
                   valid_ID = valid_ID, cents.coords = cents.coords)
rm(list = ls())
gc()
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2019", month = "09",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata") 
AggregatedFunction(year = "2019", month = "10",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2019", month = "11",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2019", month = "12",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata") 
AggregatedFunction(year = "2020", month = "01",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata") 
AggregatedFunction(year = "2020", month = "02",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2020", month = "03",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2020", month = "04",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata")
AggregatedFunction(year = "2020", month = "05",
                   valid_ID = valid_ID, cents.coords = cents.coords)
load("C:/11_Article/01_Data/02_ODMatrix/Temp2.Rdata") #next
AggregatedFunction(year = "2020", month = "06",
                   valid_ID = valid_ID, cents.coords = cents.coords)
