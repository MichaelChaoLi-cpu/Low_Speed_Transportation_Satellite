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

run <- T
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
    coef.CV1 <- coef.CV1[,1:6]
    colnames(coef.CV1) <- paste0(colnames(coef.CV1), "_Coef")
    colnames(coef.CV1)[1] <- "GridID"
    colnames(meanValueOfVariables.use) <- paste0(colnames(meanValueOfVariables.use), "_mean")
    colnames(meanValueOfVariables.use)[1] <- "GridID"
    meanValueOfVariables.use <- meanValueOfVariables.use %>% dplyr::select(-"time_mean") %>% distinct()
    
    train.predict <- left_join(train, coef.CV1, by = "GridID")
    train.predict <- left_join(train.predict, meanValueOfVariables.use, by = "GridID")
    train.predict$NTL_Coef <- train.predict$NTL_Coef %>% as.numeric()
    train.predict$NDVI_Coef <- train.predict$NDVI_Coef %>% as.numeric()
    train.predict$Temperature_Coef <- train.predict$Temperature_Coef %>% as.numeric()
    train.predict$prevalance_Coef <- train.predict$prevalance_Coef %>% as.numeric()
    train.predict$emergence_Coef <- train.predict$emergence_Coef %>% as.numeric()
    
    train.predict <- train.predict %>%
      mutate(lowSpeedDensity.predict = NTL_Coef * (NTL) + NDVI_Coef * (NDVI) + Temperature_Coef * Temperature +
               prevalance_Coef * (prevalance) + emergence_Coef * (emergence) + lowSpeedDensity_mean
      )
    train.predict$lowSpeedDensity.ori <- train.predict$lowSpeedDensity + train.predict$lowSpeedDensity_mean
    #ss.tot <- sum((train.predict$no2_measured_ug.m3.ori - mean(train.predict$no2_measured_ug.m3.ori))^2)
    ss.tot <- sum((train.predict$lowSpeedDensity.ori - mean(train.predict$lowSpeedDensity.ori))^2)
    ss.res <- sum((train.predict$lowSpeedDensity.ori - train.predict$lowSpeedDensity.predict)^2)
    CVtrain.R2 <- 1 - ss.res/ss.tot
    reg <- lm(lowSpeedDensity.predict ~ lowSpeedDensity.ori, data = train.predict)
    coeff.train = coefficients(reg)
    N.train = length(train.predict$lowSpeedDensity.predict)
    corre.train <- cor(train.predict$lowSpeedDensity.predict, train.predict$lowSpeedDensity.ori)
    rmse.train <- sqrt(ss.res/nrow(train.predict)) 
    mae.train <- mean(abs(train.predict$lowSpeedDensity.ori - train.predict$lowSpeedDensity.predict))
    
    test.predict <- left_join(test, coef.CV1, by = "GridID")
    test.predict <- left_join(test.predict, meanValueOfVariables.use, by = "GridID")
    test.predict$NTL_Coef <- test.predict$NTL_Coef %>% as.numeric()
    test.predict$NDVI_Coef <- test.predict$NDVI_Coef %>% as.numeric()
    test.predict$Temperature_Coef <- test.predict$Temperature_Coef %>% as.numeric()
    test.predict$prevalance_Coef <- test.predict$prevalance_Coef %>% as.numeric()
    test.predict$emergence_Coef <- test.predict$emergence_Coef %>% as.numeric()
    test.predict <- test.predict %>%
      mutate(lowSpeedDensity.predict = NTL_Coef * (NTL) + NDVI_Coef * (NDVI) + Temperature_Coef * Temperature +
               prevalance_Coef * (prevalance) + emergence_Coef * (emergence) + lowSpeedDensity_mean
      )
    test.predict$lowSpeedDensity.ori <- test.predict$lowSpeedDensity + test.predict$lowSpeedDensity_mean
    #ss.tot <- sum((test.predict$no2_measured_ug.m3.ori - mean(test.predict$no2_measured_ug.m3.ori))^2)
    ss.tot <- sum((test.predict$lowSpeedDensity.ori - mean(test.predict$lowSpeedDensity))^2)
    ss.res <- sum((test.predict$lowSpeedDensity.ori - test.predict$lowSpeedDensity.predict)^2)
    CVtest.R2 <- 1 - ss.res/ss.tot
    reg <- lm(lowSpeedDensity.predict ~ lowSpeedDensity.ori, data = test.predict)
    coeff.test = coefficients(reg)
    N.test = length(test.predict$lowSpeedDensity.predict)
    corre.test <- cor(test.predict$lowSpeedDensity.predict, test.predict$lowSpeedDensity.ori)
    rmse.test <- sqrt(ss.res/nrow(test.predict))
    mae.test <- mean(abs(test.predict$lowSpeedDensity.ori - test.predict$lowSpeedDensity.predict))
    
    result <- c(foldNumberth, CVtrain.R2, coeff.train, N.train, corre.train, rmse.train, mae.train,
                CVtest.R2, coeff.test, N.test, corre.test, rmse.test, mae.test)
    print(result)
    CV.result.table <- rbind(CV.result.table, result)
    foldNumberth <- foldNumberth + 1
  }
  colnames(CV.result.table) <- c("foldNumber", "CVtrain.R2", "train.inter", "train.slope", "N.train", "corre.train",
                                   "rmse.train", "mae.train",
                                   "CVtest.R2", "test.inter", "test.slope", "N.test", "corre.test", "rmse.test", "mae.test")
  write.csv(CV.result.table, file = "09_Tables/femCrossValidation.csv")
}
