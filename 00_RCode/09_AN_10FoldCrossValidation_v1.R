# Author: M.L.

# end

library(tidyverse)
library(dplyr)
library(plm)
library(GWPR.light)
library(tmap)
library(sp)

load("04_Data/00_datasetUsed.RData")
load("04_Data/00_points_mesh.in.GT.RData")
source("00_RCode/07_AF_GWPRBandwidthStepSelection_v1.R")

data.in.GT <- points_mesh.in.GT@data %>% 
  dplyr::select(GridID, PrefID)

dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)
points_mesh.in.Tokyo <- points_mesh.in.GT@data
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")
dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)

xy <- points_mesh.in.Tokyo[,c(1,2)]
points_mesh.in.Tokyo <- SpatialPointsDataFrame(coords = xy, data = points_mesh.in.Tokyo,
                                               proj4string = points_mesh.in.GT@proj4string)

formula.CV.FEM <- lowSpeedDensity ~ NTL + NDVI + Temperature + prevalance + emergence
usedDataset <- dataset_used.Tokyo

rawCrossValidationDataset <- usedDataset %>% 
  dplyr::select("GridID", "time", all.vars(formula.CV.FEM))
meanValueOfVariables <- stats::aggregate(rawCrossValidationDataset[,all.vars(formula.CV.FEM)],
                                         by = list(rawCrossValidationDataset$GridID), mean)
colnames(meanValueOfVariables)[1] <- "GridID"
meanValueOfVariablesCity <- meanValueOfVariables
meanValueOfVariables <- dplyr::left_join(dplyr::select(rawCrossValidationDataset, "GridID", "time"),
                                         meanValueOfVariables, by = "GridID")
meanValueOfVariables <- meanValueOfVariables %>% arrange("GridID", "time")
rawCrossValidationDataset <- rawCrossValidationDataset %>% arrange("GridID", "time")

#### get FEM Transformation Dataset
femTransformationDataset <- (dplyr::select(rawCrossValidationDataset, -"GridID", -"time")) - 
  (dplyr::select(meanValueOfVariables, -"GridID", -"time"))
femTransformationDataset$GridID <- rawCrossValidationDataset$GridID
femTransformationDataset$time <- rawCrossValidationDataset$time

# Randomly order dataset
source("00_RCode/08_AF_GWPRRevisedForCrossValidation_v1.R")
set.seed(42)

rows <- sample(nrow(femTransformationDataset))
femTransformationDataset <- femTransformationDataset[rows,]

singleFoldNumber <- floor(nrow(femTransformationDataset)/10)
foldNumberth <- 1

CV.result.table <- data.frame(Doubles=double(),
                              Ints=integer(),
                              Factors=factor(),
                              Logicals=logical(),
                              Characters=character(),
                              stringsAsFactors=FALSE)

run <- F
if(run){
  while (foldNumberth < 11){
    meanValueOfVariables.use <- meanValueOfVariables
    if (foldNumberth == 10){
      rows.test <- rows[((foldNumberth-1)*singleFoldNumber+1):nrow(femTransformationDataset)]
    } else {
      rows.test <- rows[((foldNumberth-1)*singleFoldNumber+1):(foldNumberth*singleFoldNumber)]
    }
    
    test <- femTransformationDataset[rows.test,]
    train <- femTransformationDataset[-rows.test,]
    
    GWPR.FEM.bandwidth = GWPR.FEM.CV.F.result$GW.arguments$bw ###
    GWPR.FEM.CV.F.result.CV1 <- GWPR.user(formula = formula.CV.FEM, data = train, index = c("GridID", "time"),
                                          SDF = points_mesh.in.Tokyo, bw = GWPR.FEM.bandwidth, adaptive = F,
                                          p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                                          model = "pooling")
    #CVtrain.R2 <- GWPR.FEM.CV.F.result.CV1$R2
    coef.CV1 <- GWPR.FEM.CV.F.result.CV1$SDF@data
    coef.CV1 <- coef.CV1[,1:17]
    colnames(coef.CV1) <- paste0(colnames(coef.CV1), "_Coef")
    colnames(coef.CV1)[1] <- "CityCode"
    colnames(meanValueOfVariables.use) <- paste0(colnames(meanValueOfVariables.use), "_mean")
    colnames(meanValueOfVariables.use)[1] <- "CityCode"
    meanValueOfVariables.use <- meanValueOfVariables.use %>% dplyr::select(-"period_mean") %>% distinct()
    
    train.predict <- left_join(train, coef.CV1, by = "CityCode")
    train.predict <- left_join(train.predict, meanValueOfVariables.use, by = "CityCode")
    train.predict <- train.predict %>%
      mutate(predictNo2 = ug_m2_troposphere_no2_Coef * (ug_m2_troposphere_no2) + 
               ter_pressure_Coef * (ter_pressure) + 
               temp_Coef * temp +
               ndvi_Coef * (ndvi) +
               precipitation_Coef * (precipitation) +
               PBLH_Coef * (PBLH) +
               Y2016_Coef * (Y2016) + Y2017_Coef * (Y2017) +
               Y2018_Coef * (Y2018) + Y2019_Coef * (Y2019) +
               Y2020_Coef * (Y2020) + Y2021_Coef * (Y2021) + no2_measured_ug.m3_mean
      )
    train.predict$no2_measured_ug.m3.ori <- train.predict$no2_measured_ug.m3 + train.predict$no2_measured_ug.m3_mean
    #ss.tot <- sum((train.predict$no2_measured_ug.m3.ori - mean(train.predict$no2_measured_ug.m3.ori))^2)
    ss.tot <- sum((train.predict$no2_measured_ug.m3.ori - mean(test.predict$no2_measured_ug.m3))^2)
    ss.res <- sum((train.predict$no2_measured_ug.m3.ori - train.predict$predictNo2)^2)
    CVtrain.R2 <- 1 - ss.res/ss.tot
    
    test.predict <- left_join(test, coef.CV1, by = "CityCode")
    test.predict <- left_join(test.predict, meanValueOfVariables.use, by = "CityCode")
    test.predict <- test.predict %>%
      mutate(predictNo2 = ug_m2_troposphere_no2_Coef * (ug_m2_troposphere_no2) + 
               ter_pressure_Coef * (ter_pressure) + 
               temp_Coef * temp +
               ndvi_Coef * (ndvi) +
               precipitation_Coef * (precipitation) +
               PBLH_Coef * (PBLH) +
               Y2016_Coef * (Y2016) + Y2017_Coef * (Y2017) +
               Y2018_Coef * (Y2018) + Y2019_Coef * (Y2019) +
               Y2020_Coef * (Y2020) + Y2021_Coef * (Y2021) + no2_measured_ug.m3_mean
      )
    test.predict$no2_measured_ug.m3.ori <- test.predict$no2_measured_ug.m3 + test.predict$no2_measured_ug.m3_mean
    #ss.tot <- sum((test.predict$no2_measured_ug.m3.ori - mean(test.predict$no2_measured_ug.m3.ori))^2)
    ss.tot <- sum((test.predict$no2_measured_ug.m3.ori - mean(test.predict$no2_measured_ug.m3))^2)
    ss.res <- sum((test.predict$no2_measured_ug.m3.ori - test.predict$predictNo2)^2)
    CVtest.R2 <- 1 - ss.res/ss.tot
    result <- c(foldNumberth, CVtrain.R2, CVtest.R2)
    print(result)
    CV.result.table <- rbind(CV.result.table, result)
    foldNumberth <- foldNumberth + 1
  }
  colnames(CV.result.table) <- c("foldNumber", "CVtrain.R2", "CVtest.R2")
  save(CV.result.table, file = "04_Results/femCrossValidation.Rdata")
  
  #PoM Cross Validation, fixed bw 2.25 
  formula.CV.PoM <-
    no2_measured_ug.m3 ~ ug_m2_troposphere_no2 + ter_pressure + temp +
    ndvi + precipitation +  PBLH +
    Y2016 + Y2017 + Y2018 + Y2019 + Y2020 + Y2021
  rawCrossValidationDataset <- usedDataset %>% 
    dplyr::select("CityCode", "period", all.vars(formula.CV.PoM))
  rawCrossValidationDataset <- rawCrossValidationDataset %>% arrange("CityCode", "period")
  pomTransformationDataset <- rawCrossValidationDataset
  pomTransformationDataset <- pomTransformationDataset[rows,]
  
  singleFoldNumber <- floor(nrow(pomTransformationDataset)/10)
  foldNumberth <- 1
  
  CV.result.pom.table <- data.frame(Doubles=double(),
                                    Ints=integer(),
                                    Factors=factor(),
                                    Logicals=logical(),
                                    Characters=character(),
                                    stringsAsFactors=FALSE)
  while (foldNumberth < 11){
    if (foldNumberth == 10){
      rows.test <- rows[((foldNumberth-1)*singleFoldNumber+1):nrow(pomTransformationDataset)]
    } else {
      rows.test <- rows[((foldNumberth-1)*singleFoldNumber+1):(foldNumberth*singleFoldNumber)]
    }
    
    test <- pomTransformationDataset[rows.test,]
    train <- pomTransformationDataset[-rows.test,]
    
    trainCode <- train %>%
      dplyr::select(CityCode) %>% distinct()
    
    trainCityLocation <- left_join(trainCode, cityLocation, by = "CityCode")
    xy <- trainCityLocation %>% dplyr::select(Longitude, Latitude)
    trainCityLocationSpatialPoint <- SpatialPointsDataFrame(coords = xy, data = cityLocation[,c(1, 2, 3, 4, 5)],
                                                            proj4string = CRS(proj))
    rm(xy)
    # get the train city points 
    
    GWPR.PoM.bandwidth = GWPR.FEM.CV.F.result$GW.arguments$bw ###
    GWPR.PoM.CV.F.result.CV1 <- GWPR(formula = formula.CV.PoM, data = train, index = c("CityCode", "period"),
                                     SDF = trainCityLocationSpatialPoint, bw = GWPR.PoM.bandwidth, adaptive = F,
                                     p = 2, effect = "individual", kernel = "bisquare", longlat = F, 
                                     model = "pooling")
    CVtrain.R2 <- GWPR.PoM.CV.F.result.CV1$R2
    coef.CV1 <- GWPR.PoM.CV.F.result.CV1$SDF@data
    coef.CV1 <- coef.CV1[,1:18]
    colnames(coef.CV1) <- paste0(colnames(coef.CV1), "_Coef")
    colnames(coef.CV1)[1] <- "CityCode"
    
    test.predict <- left_join(test, coef.CV1, by = "CityCode")
    test.predict <- test.predict %>%
      mutate(predictNo2 = ug_m2_troposphere_no2_Coef * (ug_m2_troposphere_no2) + 
               ter_pressure_Coef * (ter_pressure) + 
               temp_Coef * temp +
               ndvi_Coef * (ndvi) +
               precipitation_Coef * (precipitation) +
               PBLH_Coef * (PBLH) +
               Y2016_Coef * (Y2016) + Y2017_Coef * (Y2017) +
               Y2018_Coef * (Y2018) + Y2019_Coef * (Y2019) +
               Y2020_Coef * (Y2020) + Y2021_Coef * (Y2021) +
               Intercept_Coef
      )
    ss.tot <- sum((test.predict$no2_measured_ug.m3 - mean(test.predict$no2_measured_ug.m3))^2)
    ss.res <- sum((test.predict$no2_measured_ug.m3 - test.predict$predictNo2)^2)
    CVtest.R2 <- 1 - ss.res/ss.tot
    result <- c(foldNumberth, CVtrain.R2, CVtest.R2)
    print(result)
    CV.result.pom.table <- rbind(CV.result.pom.table, result)
    foldNumberth <- foldNumberth + 1
  }
  colnames(CV.result.pom.table) <- c("foldNumber", "CVtrain.R2", "CVtest.R2")
  save(CV.result.pom.table, file = "04_Results/pomCrossValidation.Rdata")
}