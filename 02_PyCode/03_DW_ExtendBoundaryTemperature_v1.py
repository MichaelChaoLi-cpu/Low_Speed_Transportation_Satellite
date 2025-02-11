# -*- coding: utf-8 -*-
"""
Extension of temperature raster, because some cities are close to the sea which have no data.

# Avoid using the buffer to calculate the raw data, we make this.

Created on Wed Feb  9 11:38:11 2022

@author: M.L.
"""

import numpy as np
from osgeo import gdal
import glob

###  Day Temperature
src_dataset = gdal.Open("D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Day_1km/MOD11A1_LST_Day_1km_2019_001.tif", 
                        gdal.GA_ReadOnly)
geotransform = src_dataset.GetGeoTransform()
spatialreference = src_dataset.GetProjection()
print(src_dataset.GetMetadata())
ncol = src_dataset.RasterXSize
nrow = src_dataset.RasterYSize
nband = 1
src_dataset = None

originalFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Day_1km/"
outputFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Day_1km_Ext/"

fileList = glob.glob(originalFileLocation + "/*.tif")

for file in fileList:
    raster = gdal.Open(file, gdal.GA_ReadOnly)
    rasterArray = raster.ReadAsArray()
    rasterArray = rasterArray.astype(float)
    rasterArray[rasterArray < 1] = np.nan
    
    addTimes = 0
    while addTimes < 20:
        addRasterLayer = np.full((nrow, ncol), np.nan)
        for i  in np.linspace(1,nrow-2,nrow-2, dtype = int):
            for j  in np.linspace(1, ncol-2, ncol-2, dtype = int):
                if np.isnan(rasterArray[i, j]): #addRasterLayer[316, 95] is number
                    grid = np.nanmean(rasterArray[i-1:i+2,j-1:j+2])
                    if np.isnan(grid):
                        pass
                    else:
                        addRasterLayer[i, j] = grid
        rasterArray = np.array([rasterArray, addRasterLayer])
        rasterArray = np.nanmean(rasterArray, axis = 0)
        addTimes = addTimes + 1         
    
    outputFileName = file[74:]
    finalOutputName = outputFileLocation + outputFileName
    
    # write the tif files
    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(finalOutputName, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(rasterArray)
    dst_dataset = None
    
###  Night Temperature
src_dataset = gdal.Open("D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Night_1km/MOD11A1_LST_Night_1km_2019_001.tif", 
                        gdal.GA_ReadOnly)
geotransform = src_dataset.GetGeoTransform()
spatialreference = src_dataset.GetProjection()
print(src_dataset.GetMetadata())
ncol = src_dataset.RasterXSize
nrow = src_dataset.RasterYSize
nband = 1
src_dataset = None

originalFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Night_1km/"
outputFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Night_1km_Ext/"

fileList = glob.glob(originalFileLocation + "/*.tif")

for file in fileList:
    raster = gdal.Open(file, gdal.GA_ReadOnly)
    rasterArray = raster.ReadAsArray()
    rasterArray = rasterArray.astype(float)
    rasterArray[rasterArray < 1] = np.nan
    
    addTimes = 0
    while addTimes < 20:
        addRasterLayer = np.full((nrow, ncol), np.nan)
        for i  in np.linspace(1,nrow-2,nrow-2, dtype = int):
            for j  in np.linspace(1, ncol-2, ncol-2, dtype = int):
                if np.isnan(rasterArray[i, j]): #addRasterLayer[316, 95] is number
                    grid = np.nanmean(rasterArray[i-1:i+2,j-1:j+2])
                    if np.isnan(grid):
                        pass
                    else:
                        addRasterLayer[i, j] = grid
        rasterArray = np.array([rasterArray, addRasterLayer])
        rasterArray = np.nanmean(rasterArray, axis = 0)
        addTimes = addTimes + 1         
    
    outputFileName = file[76:]
    finalOutputName = outputFileLocation + outputFileName
    
    # write the tif files
    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(finalOutputName, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(rasterArray)
    dst_dataset = None
