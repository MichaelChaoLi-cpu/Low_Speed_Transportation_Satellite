#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 19 19:35:01 2023

@author: lichao
"""

from M11_AN_RunXgbAndShap_v1 import runLocallyOrRemotely


from glob import glob
from netCDF4 import Dataset
import numpy as np
import pandas as pd


def getIdXy():
    dataset_to_analysis = pd.read_csv(REPO_RESULT_LOCATION + 'mergedXSHAP.csv')
    dataset_to_analysis = dataset_to_analysis[['GridID', 'x', 'y']]
    dataset_to_analysis = dataset_to_analysis.drop_duplicates()
    return dataset_to_analysis

def getNewControlVar(IdXy_Df):
    nc_file_list = glob(REPO_DATA_LOCATION + "rawNC/*.nc")
    
    total_dataset = []
    for nc_file_name in nc_file_list:
        nc_file = Dataset(nc_file_name, 'r')
        
        longitude = nc_file.variables['X'][:]
        latitude = nc_file.variables['Y'][:]
        time = nc_file.variables['time'][:]
        
        month_dataset = []
        print(f"{float(nc_file_name[-13:-7])}, {type(float(nc_file_name[-13:-7]))}")
        for i in list(range(IdXy_Df.shape[0])):
            time_stamp = float(nc_file_name[-13:-7])
            GridID = IdXy_Df.iloc[i,0]
            x = IdXy_Df.iloc[i,1]
            y = IdXy_Df.iloc[i,2]
            
            x_index = (abs(longitude - x)).argmin()
            y_index = (abs(latitude - y)).argmin()
            tair_values = floatJuger(nc_file.variables['Tair_f_tavg'][:, y_index, x_index][0] - 273.15)
            psurf_values = floatJuger(nc_file.variables['Psurf_f_tavg'][:, y_index, x_index][0] / 1000)
            qair_values = floatJuger(nc_file.variables['Qair_f_tavg'][:, y_index, x_index][0])
            wind_values = floatJuger(nc_file.variables['Wind_f_tavg'][:, y_index, x_index][0])
            rainf_values = floatJuger(nc_file.variables['Rainf_f_tavg'][:, y_index, x_index][0])
            
            row = [GridID, time_stamp, tair_values, psurf_values, qair_values,
                   wind_values, rainf_values]
            month_dataset.append(row)
            if i%2000 == 0:
                print(f'{time_stamp}: {i}')
                #break
        total_dataset = total_dataset + month_dataset
    total_dataset = pd.DataFrame(total_dataset)
    total_dataset.columns = ["GridID", "time", "tair", "psurf", "qair",
                             "wind", "rainf"]
    return total_dataset

def floatJuger(num):
    try:
        num = float(num)
        return num
    except:
        return np.nan
    

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('mac')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    REPO_DATA_LOCATION = REPO_LOCATION + '04_Data/'
    
    IdXy_Df = getIdXy()
    NewControlDataset = getNewControlVar(IdXy_Df)
    NewControlDataset.to_csv(REPO_DATA_LOCATION + "18_AdditionalControlVariFromNoah0.1.csv",
                             index=False)
    
    
