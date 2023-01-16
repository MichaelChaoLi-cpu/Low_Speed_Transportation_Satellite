# Spatially Varied Connections between Human Activity and Satellite Observations in Tokyo (DP11)   
This is the repo for the DP11. There should be a relationship between low-speed transportation and satellite data.     
    
Human activity significantly affects urban economics, vitality, and development. Owing to the availability of comprehensive and high-resolution satellite observations, a variety of information of interest is obtained or estimated effectively and efficiently. Satellite observations are generally proxied to represent and probe human activity. However, substantial evidence to support the connections between human activity and satellite data is relatively rare. Here, we use geographically weighted panel regression (GWPR) to examine the relationship between low-speed transportation and several satellite data, including nighttime light (NTL), greenness, temperature, as well as COVID-19-related variables from January 2019 to December 2020. The accuracy of our model is 97.50%, and the model is reliable according to the 10-fold cross-validation. Our result shows that a 1-unit increase in NTL in highly developed areas is associated with more human activity growth. The only increased greenness in the publicly accessible parks could attract more people, while warmer weather consistently increases low-speed transportation. Overall, this research provides solid evidence to connect human activity and satellite data to academia, governments, and societies.    
     
## Author    
Chao Li, Alexander Ryota Keeley, Shunsuke Managi    
     
## Result:    
### Spatial Distribution of the NTL Coefficients in GWPR (a: the part of Tokyo on Honshu Island; b: Oshima Machi)    
![](06_Figure/NTL.Coeff.jpeg)    
      
### Spatial Distribution of the NDVI Coefficients in GWPR     
![](06_Figure/NDVI.Coeff.jpeg)    
     
### Spatial Distribution of the Temperature Coefficients in GWPR   
![](06_Figure/Temperature.Coeff.jpeg)     
     
### Spatial Distribution of the COVID-19 Prevalence Coefficients in GWPR     
![](06_Figure/prevalance.Coeff.jpeg)     
     
### Spatial Distribution of the COVID-19 Lockdown Ratio Coefficients in GWPR    
![](06_Figure/emergence.Coeff.jpeg)   
    
## R Code  
[01_DW_GridRealMovementEstimation_v1.R](00_RCode/01_DW_GridRealMovementEstimation_v1.R): This script is to wash the data to get low speed transportation density from 2019.01 to 2020.12, a total of 24 months of Tokyo (28600 grids 24 months).    
[02_DW_GridDataConstructionLowSpeed_v1.R](00_RCode/02_DW_GridDataConstructionLowSpeed_v1.R): This script is to make the the low-speed transportation dataset.   
[03_DW_GridDataControlVariable_v1.R](00_RCode/03_DW_GridDataControlVariable_v1.R): This script is to build the dataset including the varibales of interest, including low-speed transportation, NTL, NDVI, temperature, prevalence, lockdown ratio. The accuracy of the model is 97.50%.     
[04_AN_GWPRLowSpeedOtherVariables_v1.R](00_RCode/04_AN_GWPRLowSpeedOtherVariables_v1.R): This is to run GWPR model with 0.015 degree. The accuracy of the model is 97.50%.     
[05_AN_ResultValidation_v1.R](00_RCode/05_AN_ResultValidation_v1.R): This is to temporal validation of results.    
[06_VI_FigureInManu_v2.R](00_RCode/06_VI_FigureInManu_v2.R): this is to visual figures except maps.    
[07_AF_GWPRBandwidthStepSelection_v1.R](00_RCode/07_AF_GWPRBandwidthStepSelection_v1.R): This script revises the function in GWPR.light to perform step bandwidth selection.   
[08_AF_GWPRRevisedForCrossValidation_v1.R](00_RCode/08_AF_GWPRRevisedForCrossValidation_v1.R): This script is the CV funciton.     
[09_AN_10FoldCrossValidation_v1.R](00_RCode/09_AN_10FoldCrossValidation_v1.R): This script is to run 10-fold CV.     
[10_VI_LocationAndMaps_v1.R](00_RCode/10_VI_LocationAndMaps_v1.R): This script is to visualize the maps.     
      
## Workflow
**WF.A: (01, 02) -> 03 -> 04 -> 05 -> 09 -> (06, 10) -> END**     
**WF.A.0102.03**: This step is to make the dataset to use in the analysis.      
**WF.A.03.04**: This step conducts the analysis using GWPR based on FEM with **Fixed** distance bandwidth.    
**WF.A.04.05**: This step conducts temporal validation of results.    
**WF.A.05.09**: This step is to run 10-fold CV.    
**WF.A.09.0610**: This step is to visualize.    
     
## Contact Us:    
- Email: Prof. Shunsuke Managi <managi@doc.kyushu-u.ac.jp>  
- Email: Assistant Prof. Alexander Ryota Keeley <keeley.ryota.alexander.416@m.kyushu-u.ac.jp>
- Email: Chao Li <chaoli0394@gmail.com>    
      
## Term of Use:
Authors/funders retain copyright (where applicable) of code on this Github repo. This GitHub repo and its contents herein, including data, link to data source, and analysis code that are intended solely for reproducing the results in the manuscript "Spatially Varied Connections between Human Activity and Satellite Observations in Tokyo". The analyses rely upon publicly available data from multiple sources, that are often updated without advance notice. We hereby disclaim any and all representations and warranties with respect to the site, including accuracy, fitness for use, and merchantability. By using this site, its content, information, and software you agree to assume all risks associated with your use or transfer of information and/or software. You agree to hold the authors harmless from any claims relating to the use of this site.  
