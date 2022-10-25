# -*- coding: utf-8 -*-
"""
Created on Fri Oct 21 15:59:59 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import numpy as np
from osgeo import gdal
import glob
import os
from datetime import datetime

###  Day Temperature
src_dataset = gdal.Open("D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/MergedMODIS/temp_2019_001.tif", 
                        gdal.GA_ReadOnly)
geotransform = src_dataset.GetGeoTransform()
spatialreference = src_dataset.GetProjection()
print(src_dataset.GetMetadata())
ncol = src_dataset.RasterXSize
nrow = src_dataset.RasterYSize
nband = 1
src_dataset = None

originalFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/MergedMODIS/"
outputFileLocation = "D:/11_Article/01_Data/06_Tempature/Surf_Temp_Daily_1Km_v6/MergedMODISMonth/"

def moveRawTifandRename(originalFileLocation):
    fileList = glob.glob(originalFileLocation + "/*.tif")
    for filename in fileList:
        year = filename[75:79]
        day = filename[80:83]
        res = datetime.strptime(year + "-" + day, "%Y-%j").strftime("%Y-%m-%d")
        new_name = filename[0:75] + res +'.tif'
        os.rename(filename, new_name)

if __name__=="__main__":
    moveRawTifandRename(originalFileLocation)