# Author: M.L.


# Note: this script is used for Supercomputer 

# end

# once we meet the problem such as 
##### bad restore file magic number (file may be corrupted) -- no data loaded
# it means that we have to use the write.csv() function rather than save() function.

# NOTE: when we use the package we have to check the version of the packages
##### for example the super computer R --version is 3.4.2
##### so we always use the lower version package around that year 2013
 
load("04_Data/00_datasetUsed.RData")

load("04_Data/00_points_mesh.in.GT.RData")
points_mesh.in.GT <- points_mesh.in.GT@data
#write.csv(points_mesh.in.GT, file = "04_Data/SP_00_points_mesh.in.GT.RData")

data.in.GT <- points_mesh.in.GT %>% 
  dplyr::select(GridID, PrefID)

dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)

dataset_used$lowSpeedDensity_num <- dataset_used$lowSpeedDensity
dataset_used$lowSpeedDensity <- log(dataset_used$lowSpeedDensity + 1)


formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence
points_mesh.in.Tokyo <- points_mesh.in.GT
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")

dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)
write.csv(points_mesh.in.Tokyo, file = "04_Data/SP_00_points_mesh.in.Tokyo.RData")
write.csv(dataset_used.Tokyo, file = "04_Data/SP_00_dataset_used.Tokyo.RData")

dataset_used.test <- dataset_used.Tokyo
dataset_used.test$GridID <- dataset_used.test$GridID %>% as.numeric()
dataset_used.test <- dataset_used.test %>%
  filter(GridID < 5239150000)
dataset_used.test$GridID <- dataset_used.test$GridID %>% as.character()

points_mesh.test <- points_mesh.in.Tokyo
points_mesh.test$GridID <- points_mesh.test$GridID %>% as.numeric()
points_mesh.test <- points_mesh.test %>%
  filter(GridID < 5239150000)
points_mesh.test$GridID <- points_mesh.test$GridID %>% as.character()

write.csv(points_mesh.test, file = "04_Data/SP_00_points_mesh.test.RData")
write.csv(dataset_used.test, file = "04_Data/SP_00_dataset_used.test.RData")
