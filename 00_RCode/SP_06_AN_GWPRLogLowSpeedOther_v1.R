# Author: M.L.


# Note: this script is used for Supercomputer 

# end

load("04_Data/00_datasetUsed.RData")
load("04_Data/00_points_mesh.in.GT.RData")
source("00_RCode/07_AF_GWPRBandwidthStepSelection_v1.R")

data.in.GT <- points_mesh.in.GT@data %>% 
  dplyr::select(GridID, PrefID)

dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)

dataset_used$lowSpeedDensity_num <- dataset_used$lowSpeedDensity
dataset_used$lowSpeedDensity <- log(dataset_used$lowSpeedDensity + 1)

formula <- lowSpeedDensity ~ temp +  NDVI + prevalance + emergence
points_mesh.in.Tokyo <- points_mesh.in.GT@data
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")

dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)

load("04_Data/00_points_mesh.in.Tokyo.RData")

### search log movement bandwidth for 0.02 to 0.50, step is 0.005 
not_get_result <- T
if(not_get_result){
  formula
  #formula <- lowSpeedDensity_num ~ temp +  NDVI + prevalance + emergence
  GWPR.FEM.bandwidth <- # this is about fixed bandwidth
    bw.GWPR.step.selection(formula = formula, data = dataset_used.Tokyo, index = c("GridID", "time"),
                           SDF = points_mesh.in.Tokyo, adaptive = F, p = 2, bigdata = F,
                           upperratio = 0.10, effect = "individual", model = "within", approach = "CV",
                           kernel = "bisquare",doParallel = T, cluster.number = 70, gradientIncrecement = T,
                           GI.step = 0.005, GI.upper = 0.5, GI.lower = 0.02)
  GWPR.FEM.bandwidth.step.list <- GWPR.FEM.bandwidth
  save(GWPR.FEM.bandwidth.step.list, file = "03_Results/GWPR_BW_setp_list.Tokyo.log.002.05.0005.Rdata")
  not_get_result <- F
}
