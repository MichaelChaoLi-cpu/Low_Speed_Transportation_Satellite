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


# here is to test the raster
centroids_mesh <- gCentroid(mesh_grid, byid = T, id = mesh_grid$GridID)
points_mesh <- coordinates(centroids_mesh) %>% as.data.frame()
points_mesh <- cbind(points_mesh, mesh_grid@data)
xy <- points_mesh[,c(1,2)]
proj <- mesh_grid@proj4string
points_mesh <- SpatialPointsDataFrame(coords = xy, data = ,
                                      proj4string = proj)
points_mesh.raster <- SpatialPixelsDataFrame(points = xy, data = points_mesh@data, tolerance = 0.15)
points_mesh.raster <- as(points_mesh.raster, "SpatialGridDataFrame")
points_mesh.raster@data <- points_mesh.raster@data %>% dplyr::select(Density)
points_mesh.raster <- raster(points_mesh.raster)
plot(points_mesh.raster)
