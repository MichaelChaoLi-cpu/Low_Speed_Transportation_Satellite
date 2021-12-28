# NVDI_and_Low_Speed_Transportation
This is the repo for the DP11. There should be a relationship between low speed transportation and NDVI. 

## Data  
OD_data: use the cell phone locations to detect the movements, monthly  
NDVI: MOD13, monthly  
Weather: M*D07, daily  
NTL: VNP46A2 500m, monthly  
WorldPop: 1km, yearly  
  
## Code  
[01_DW_GridRealMovementEstimation_v1.R](00_RCode/01_DW_GridRealMovementEstimation_v1.R): This script is to wash the data to get low speed transportation density from 2019.01 to 2021.01, a total of 25 months of the Great Tokyo Area. 