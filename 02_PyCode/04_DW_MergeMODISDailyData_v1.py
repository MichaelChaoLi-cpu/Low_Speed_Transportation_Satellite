# -*- coding: utf-8 -*-
"""
Average MOD11A1 and MYD11A1, including day and night

Mehtod: average

Source: MOD11A1 and MYD11A!

Resolution: 1km

Created on Tue Mar 22 11:24:43 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

from osgeo import gdal
import os
import numpy as np

rasterDayFolder = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Day_1km/"
rasterNightFolder = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/LST_Night_1km/"

rasterFilesDay = os.listdir(rasterDayFolder)
rasterFilesNight = os.listdir(rasterNightFolder)
        
loop = 0 

while (loop < len(rasterFilesDay)/2):
    ## Open tiff file
    tifflayer_day_MOD = gdal.Open(rasterDayFolder + rasterFilesDay[loop], gdal.GA_ReadOnly)
    geotransform = tifflayer_day_MOD.GetGeoTransform()
    spatialreference = tifflayer_day_MOD.GetProjection()
    MYD_loop = loop + int(len(rasterFilesDay)/2)
    tifflayer_day_MYD = gdal.Open(rasterDayFolder + rasterFilesDay[MYD_loop], gdal.GA_ReadOnly)
    tifflayer_night_MOD = gdal.Open(rasterNightFolder + rasterFilesNight[loop], gdal.GA_ReadOnly)
    tifflayer_night_MYD = gdal.Open(rasterNightFolder + rasterFilesNight[MYD_loop], gdal.GA_ReadOnly)
    
    tifflayer_day_MOD_Array = tifflayer_day_MOD.ReadAsArray()
    tifflayer_day_MOD_Array = tifflayer_day_MOD_Array.astype(np.float)
    tifflayer_day_MOD_Array[tifflayer_day_MOD_Array == 0] = np.nan
    
    tifflayer_day_MYD_Array = tifflayer_day_MYD.ReadAsArray()
    tifflayer_day_MYD_Array = tifflayer_day_MYD_Array.astype(np.float)
    tifflayer_day_MYD_Array[tifflayer_day_MYD_Array == 0] = np.nan
    
    tifflayer_night_MOD_Array = tifflayer_night_MOD.ReadAsArray()
    tifflayer_night_MOD_Array = tifflayer_night_MOD_Array.astype(np.float)
    tifflayer_night_MOD_Array[tifflayer_night_MOD_Array == 0] = np.nan
    
    tifflayer_night_MYD_Array = tifflayer_night_MYD.ReadAsArray()
    tifflayer_night_MYD_Array = tifflayer_night_MYD_Array.astype(np.float)
    tifflayer_night_MYD_Array[tifflayer_night_MYD_Array == 0] = np.nan
    
    aim_array = [tifflayer_day_MOD_Array, tifflayer_day_MYD_Array, tifflayer_night_MOD_Array, tifflayer_night_MYD_Array]
    aim_array = np.nanmean(aim_array, axis=0)
    
    outputFolder = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/MergedMODIS/"
    
    name = 'temp_' + rasterFilesDay[loop][-12:]
    outputRaster = outputFolder + name
    
    driver = gdal.GetDriverByName("GTiff")
    dst_dataset = driver.Create(outputRaster, 489, 400, 1, gdal.GDT_Float32)
    dst_dataset.SetGeoTransform(geotransform)
    dst_dataset.SetProjection(spatialreference)
    dst_dataset.GetRasterBand(1).WriteArray(aim_array)
    dst_dataset = None
    loop = loop + 1