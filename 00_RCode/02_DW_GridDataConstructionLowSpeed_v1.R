# Author: M.L.

# input: raw_data_20XX_XX.20_.qX.csv
# raw_data_20XX_XX.20_.qX.csv: "Group.1" this is the grid id to finish spatial join.
# raw_data_20XX_XX.20_.qX.csv: "x" estimation of the flow on a certain grid.

# end

library(tidyverse)
library(dplyr)
library(rgdal)
library(stringr)
library(rgeos)
library(raster)

setwd("D:/11_Article/01_Data/04_WashedData")
filelist <- list.files()
filelist.csv <- c()
for(filename in filelist) {
  if(str_sub(filename, 1, 8) == 'raw_data'){
    filelist.csv <- append(filelist.csv, filename)
  }
}
rm(filelist)

setwd("D:\\11_Article\\01_Data\\01_mesh\\")
mesh_grid <- readOGR(dsn = ".", layer = "MeshFile")
mesh_grid@data <- mesh_grid@data %>%
  dplyr::select(G04d_001)
colnames(mesh_grid@data) <- c("GridID")
mesh_grid.ori <- mesh_grid

makingMeshWithDensity <- function(aim_year, aim_month, filelist.csv, mesh_grid){
  setwd("D:/11_Article/01_Data/04_WashedData")
  single.year.filelist <- c()
  for(filename in filelist.csv) {
    if(str_sub(filename, 10, 13) == aim_year){
      if(str_sub(filename, 15, 16) == aim_month){
        single.year.filelist <- append(single.year.filelist, filename)
      }
    }
  }
  
  transportation.density.dataset <- data.frame(Doubles=double(), Ints=integer(), Factors=factor(),
                                               Logicals=logical(), Characters=character(),
                                               stringsAsFactors=FALSE)
  for(filename in single.year.filelist){
    q.dataset <- read.csv(filename)
    transportation.density.dataset <- rbind(transportation.density.dataset,  q.dataset)
  }
  
  colnames(transportation.density.dataset) <- c("X", "GridID", "Density")
  transportation.density.dataset <- transportation.density.dataset %>% filter(!is.na(Density))
  transportation.density.dataset <- aggregate(transportation.density.dataset$Density, 
                                              by = list(transportation.density.dataset$GridID),
                                              "sum")
  colnames(transportation.density.dataset) <- c("GridID", "Density")
  transportation.density.dataset$GridID <- transportation.density.dataset$GridID %>% as.character()
  
  mesh_grid@data <- left_join(mesh_grid@data, transportation.density.dataset, by = "GridID")
  mesh_grid@data <- mesh_grid@data %>%
    mutate(Density = ifelse(is.na(Density), 0, Density))
  colnames(mesh_grid@data)[length(colnames(mesh_grid@data))] <- paste0("Density", aim_year, aim_month)
  return(mesh_grid)
}

month_list <- c("01", "02", "03", "04", "05", "06",
                "07", "08", "09", "10", "11", "12")

for (month in month_list) {
  mesh_grid <- makingMeshWithDensity("2019", month, filelist.csv, mesh_grid)
}
for (month in month_list) {
  mesh_grid <- makingMeshWithDensity("2020", month, filelist.csv, mesh_grid)
}
mesh_grid <- makingMeshWithDensity("2021", "01", filelist.csv, mesh_grid)

# here is to test the raster
centroids_mesh <- gCentroid(mesh_grid, byid = T, id = mesh_grid$GridID)
points_mesh <- coordinates(centroids_mesh) %>% as.data.frame()
points_mesh <- cbind(points_mesh, mesh_grid@data)
xy <- points_mesh[,c(1,2)]
proj <- mesh_grid@proj4string
points_mesh <- SpatialPointsDataFrame(coords = xy, data = points_mesh,
                                      proj4string = proj)
points_mesh.raster.ori <- SpatialPixelsDataFrame(points = xy, data = points_mesh@data, tolerance = 0.15)
points_mesh.raster.ori <- as(points_mesh.raster.ori, "SpatialGridDataFrame")
key_variable <- colnames(points_mesh.raster.ori@data)
key_variable <- key_variable[4:length(key_variable)]

setwd("C:/Users/li.chao.987@s.kyushu-u.ac.jp/OneDrive - Kyushu University/11_Article/03_RStudio")
predict_jpg_folder <- "01_Figure/00_DensityTest/"
for (variable in key_variable){
  points_mesh.raster <- points_mesh.raster.ori
  points_mesh.raster@data <- points_mesh.raster@data %>% dplyr::select(variable %>% as.character())
  points_mesh.raster <- raster(points_mesh.raster)
  brks = c(0, 1000, 10000, 100000, 1000000, 10000000)
  pal <- colorRampPalette(c("blue","green","yellow","red"))
  jpeg(paste0(predict_jpg_folder,variable %>% as.character(),".jpg"), 
       quality = 300, width = 1300, height = 1000)
  plot(points_mesh.raster, breaks = brks, col = pal(6))
  dev.off()
}
