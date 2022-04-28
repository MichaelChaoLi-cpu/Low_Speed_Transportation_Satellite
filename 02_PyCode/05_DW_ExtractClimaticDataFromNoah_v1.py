# -*- coding: utf-8 -*-
"""
Created on Thu Apr 28 14:37:41 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import numpy as np
import os
from scipy.io import netcdf
import netCDF4
from osgeo import gdal
import glob

src_dataset = gdal.Open("D:/10_Article/08_MonthlyRaster/IDW_REM/200702.tif")
geotransform = (-180.0, 0.1, 0.0, 90.0, 0.0, -0.1)
spatialreference = src_dataset.GetProjection()
ncol = 3600
nrow = 1500
nband = 1

aimFolder = "D:\\11_Article\\01_Data\\07_ClimaticData"
fileList = glob.glob(aimFolder + "\\*.nc")

os.mkdir(aimFolder + "\\temp")

for fileName in fileList:
    readNc4File = netCDF4.Dataset(fileName)
    totalPrecipitationRate = readNc4File["Rainf_f_tavg"][:] 
    totalPrecipitationRate = np.nanmean(totalPrecipitationRate, axis = 0)
    totalPrecipitationRate = totalPrecipitationRate[::-1,:]
    totalPrecipitationRateOutputRaster = aimFolder + "\\temp\\" + \
        'totalPrecipitationRate_' + fileName[60:66] + ".tif"
        
    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(totalPrecipitationRateOutputRaster, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(totalPrecipitationRate)
    dst_dataset = None
    
    specificHumidity = readNc4File["Qair_f_tavg"][:]
    specificHumidity = np.nanmean(specificHumidity, axis = 0)
    specificHumidity = specificHumidity[::-1,:]
    specificHumidityOutputRaster = aimFolder + "\\temp\\" + \
        'specificHumidity_' + fileName[60:66] + ".tif"

    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(specificHumidityOutputRaster, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(specificHumidity)
    dst_dataset = None
    
    airPressure = readNc4File["Psurf_f_tavg"][:]
    airPressure = np.nanmean(airPressure, axis = 0)
    airPressure = airPressure[::-1,:]
    airPressureOutputRaster = aimFolder + "\\temp\\" + \
        'airPressure_' + fileName[60:66] + ".tif"

    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(airPressureOutputRaster, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(airPressure)
    dst_dataset = None
    
    shortWave = readNc4File["Swnet_tavg"][:]
    shortWave = np.nanmean(shortWave, axis = 0)
    shortWave = shortWave[::-1,:]
    shortWaveOutputRaster = aimFolder + "\\temp\\" + \
        'shortWave_' + fileName[60:66] + ".tif"

    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(shortWaveOutputRaster, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(shortWave)
    dst_dataset = None
    
    windSpeed = readNc4File["Wind_f_tavg"][:]
    windSpeed = np.nanmean(windSpeed, axis = 0)
    windSpeed = windSpeed[::-1,:]
    windSpeedOutputRaster = aimFolder + "\\temp\\" + \
        'windSpeed_' + fileName[60:66] + ".tif"

    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(windSpeedOutputRaster, ncol, nrow, nband, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(windSpeed)
    dst_dataset = None
    
    