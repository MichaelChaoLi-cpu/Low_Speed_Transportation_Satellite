# -*- coding: utf-8 -*-
"""
Created on Wed Oct 26 11:37:14 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import numpy as np
from osgeo import gdal
import glob
import os
from datetime import datetime

###  NDVI
src_dataset = gdal.Open("D:/11_Article/01_Data/03_NDVI/VI_16Days_250m_v6/NDVI/MOD13Q1_NDVI_2019_001.tif", 
                        gdal.GA_ReadOnly)
geotransform = src_dataset.GetGeoTransform()
spatialreference = src_dataset.GetProjection()
print(src_dataset.GetMetadata())
ncol = src_dataset.RasterXSize
nrow = src_dataset.RasterYSize
nband = 1
src_dataset = None

def makeDirIfNotExist(path):
    isExist = os.path.exists(path)
    if not isExist:
        os.makedirs(path)
        print("The new directory is created!")
    else:
        print(path + " is there!")
        
def renameTif(originalFileLocation):
    fileList = glob.glob(originalFileLocation + "/*.tif")
    for filename in fileList:
        year = filename[66:70]
        day = filename[71:74]
        res = datetime.strptime(year + "-" + day, "%Y-%j").strftime("%Y-%m-%d")
        new_name = filename[0:66] + res +'.tif'
        os.rename(filename, new_name)
        
def mergeMonthlyDataset(originalFileLocation, outputFileLocation):
    makeDirIfNotExist(outputFileLocation)
    ### create a new folder
    years = ["2019", "2020"]
    months = ["01", "02", "03", '04', '05', '06',
             '07', '08', '09', '10', '11', '12']
    fileList = glob.glob(originalFileLocation + "/*.tif")
    res = []
    for year in years:
        for month in months:
            for file in fileList:
                if year + '-' + month in file:
                    ds = gdal.Open(file)
                    res.append(ds.GetRasterBand(1).ReadAsArray())
            stacked = np.dstack(res) 
            mean = np.nanmean(stacked, axis=-1)
            outputRaster = outputFileLocation + year + '-' + month + '.tif'
            
            driver = gdal.GetDriverByName("GTiff")
            dst_dataset = driver.Create(outputRaster, ncol, nrow, nband, gdal.GDT_Float32)
            dst_dataset.SetGeoTransform(geotransform)
            dst_dataset.SetProjection(spatialreference)
            dst_dataset.GetRasterBand(1).WriteArray(mean)
            dst_dataset = None
            print(year + '-' + month)


def extendCoverage(originalFileLocation, outputFileLocation):
    makeDirIfNotExist(outputFileLocation)
    fileList = glob.glob(originalFileLocation + "/*.tif")

    for file in fileList:
        raster = gdal.Open(file, gdal.GA_ReadOnly)
        rasterArray = raster.ReadAsArray()
        rasterArray = rasterArray.astype(float)
        rasterArray[rasterArray < 1] = np.nan
        
        addTimes = 0
        while addTimes < 40:
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
        
        outputFileName = file[-11:]
        finalOutputName = outputFileLocation + outputFileName
        
        # write the tif files
        driver = gdal.GetDriverByName("GTiff")
        dst_dataset = driver.Create(finalOutputName, ncol, nrow, nband, gdal.GDT_Float32)
        dst_dataset.SetGeoTransform(geotransform)
        dst_dataset.SetProjection(spatialreference)
        dst_dataset.GetRasterBand(1).WriteArray(rasterArray)
        dst_dataset = None
        

if __name__=="__main__":
    originalFileLocation = "D:/11_Article/01_Data/03_NDVI/VI_16Days_250m_v6/NDVI/"
    outputFileLocation = "D:/11_Article/01_Data/03_NDVI/VI_16Days_250m_v6/MergedNDVI/"
    renameTif(originalFileLocation)
    mergeMonthlyDataset(originalFileLocation, outputFileLocation)
    
    extendFileLocation = "D:/11_Article/01_Data/03_NDVI/VI_16Days_250m_v6/ExtendNDVI/"
    extendCoverage(outputFileLocation, extendFileLocation)

