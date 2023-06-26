#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 19 15:00:09 2023

@author: lichao
"""

from M11_AN_RunXgbAndShap_v1 import runLocallyOrRemotely

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

def getShapDf():
    dataset_to_analysis = pd.read_csv(REPO_RESULT_LOCATION + '03_mergedXSHAPStdize_noah_withoutAP.csv')
    dataset_to_analysis = dataset_to_analysis.set_index(['GridID', 'time'])
    return dataset_to_analysis


def plotValueShap(Dataset_Shap_Df):
    #variable_of_interest = list(Dataset_Shap_Df.columns[1:19])
    
    X_colname = ['tair', 'psurf', 'qair', 'wind', 'rainf', 
                 'NTL', 'NDVI', 
                 'UVAerosolIndex', 'PBLH', 
                 'prevalance', 'mortality', 'emergence',  
                 'x', 'y'
                 ]
    sub_order = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
                 'l', 'm', 'n'
                 ]
    feature_name = ["Temperature", "Air Pressure", "Humidity", "Wind Speed", 
                    "Precipitation", "NTL", "NDVI", 
                    "UV Index", "PBLH", "Prevalence",
                    "Mortality", "Emergence", 
                    "Longitude", "Latitude"]
    fig, axs = plt.subplots(nrows=4, ncols=4, figsize=(29.7, 21), dpi=300)
    for i, variable_name in enumerate(X_colname):
        if i < 14:
            i_row, i_col = i//4, i%4
            text_x = np.min(Dataset_Shap_Df[variable_name]) + 0.01 * (np.max(Dataset_Shap_Df[variable_name])-np.min(Dataset_Shap_Df[variable_name]))
            text_y = np.max(Dataset_Shap_Df[variable_name+'_shap']) - 0.03 * (np.max(Dataset_Shap_Df[variable_name+'_shap'])-np.min(Dataset_Shap_Df[variable_name+'_shap']))
            axs[i_row, i_col].scatter(Dataset_Shap_Df[variable_name], 
                                      Dataset_Shap_Df[variable_name+'_shap'], alpha=0.05,
                                      marker = '.', linewidths=0)
            axs[i_row, i_col].grid(True)
            if variable_name == 'year':
                axs[i_row, i_col].text(2019, 0.18, sub_order[i], fontsize=20, weight='bold', color='r')
            else:
                axs[i_row, i_col].text(text_x, text_y, sub_order[i], fontsize=20, weight='bold', color='r')
            axs[i_row, i_col].set_xlabel(feature_name[i], fontsize=15)
            axs[i_row, i_col].set_ylabel(feature_name[i] + ' SHAP', fontsize=15)
    for i in range(len(X_colname), 16):  
        i_row, i_col = i//4, i%4
        axs[i_row, i_col].axis('off')
    plt.show(); 
    fig.savefig(REPO_FIGURE_LOCATION + "All_SHAP.jpg", bbox_inches='tight')
    return None

def getShapDf1():
    dataset_to_analysis = pd.read_csv(REPO_RESULT_LOCATION + '04_mergedXSHAPStdize_noah_withAP.csv')
    dataset_to_analysis = dataset_to_analysis.set_index(['GridID', 'time'])
    return dataset_to_analysis


def plotValueShap1(Dataset_Shap_Df):
    #variable_of_interest = list(Dataset_Shap_Df.columns[1:19])
    
    X_colname = ['tair', 'psurf', 'qair', 'wind', 'rainf', 
                 'NTL', 'NDVI', 
                 'mg_m2_troposphere_no2', 'ozone', 
                 'UVAerosolIndex', 'PBLH', 
                 'prevalance', 'mortality', 'emergence', 
                 'x', 'y'
                 ]
    sub_order = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
                 'l', 'm', 'n', 'o', 'p'
                 #, 'q', 'r'
                 ]
    feature_name = ["Temperature", "Air Pressure", "Humidity", "Wind Speed", 
                    "Precipitation", "NTL", "NDVI", 
                    "NO2", "Ozone",
                    "UV Index", "PBLH", "Prevalence",
                    "Mortality", "Emergence", 
                    "Longitude", "Latitude"]
    fig, axs = plt.subplots(nrows=6, ncols=3, figsize=(21, 29.7), dpi=300)
    for i, variable_name in enumerate(X_colname):
        i_row, i_col = i//3, i%3
        text_x = np.min(Dataset_Shap_Df[variable_name]) + 0.01 * (np.max(Dataset_Shap_Df[variable_name])-np.min(Dataset_Shap_Df[variable_name]))
        text_y = np.max(Dataset_Shap_Df[variable_name+'_shap']) - 0.03 * (np.max(Dataset_Shap_Df[variable_name+'_shap'])-np.min(Dataset_Shap_Df[variable_name+'_shap']))
        axs[i_row, i_col].scatter(Dataset_Shap_Df[variable_name], 
                                  Dataset_Shap_Df[variable_name+'_shap'], alpha=0.05,
                                  marker = '.', linewidths=0)
        axs[i_row, i_col].grid(True)
        if variable_name == 'year':
            axs[i_row, i_col].text(2019, 0.18, sub_order[i], fontsize=20, weight='bold', color='r')
        else:
            axs[i_row, i_col].text(text_x, text_y, sub_order[i], fontsize=20, weight='bold', color='r')
        axs[i_row, i_col].set_xlabel(feature_name[i], fontsize=15)
        axs[i_row, i_col].set_ylabel(feature_name[i] + ' SHAP', fontsize=15)
    plt.show(); 
    fig.savefig(REPO_FIGURE_LOCATION + "All_SHAP1.jpg", bbox_inches='tight')
    return None

def plotTempShapMonthly(Dataset_Shap_Df):
    months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
              'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
    variable_name = 'tair'
    fig, axs = plt.subplots(nrows=4, ncols=3, figsize=(21, 29.7), dpi=300)
    for i, month in enumerate(months):
        data_use = Dataset_Shap_Df[Dataset_Shap_Df['month'] == i + 1]
        print(np.mean(data_use[variable_name]))
        i_row, i_col = i//3, i%3
        text_x = np.min(data_use[variable_name]) + 0.01 * (np.max(data_use[variable_name])-np.min(data_use[variable_name]))
        text_y = np.max(data_use[variable_name+'_shap']) - 0.03 * (np.max(data_use[variable_name+'_shap'])-np.min(data_use[variable_name+'_shap']))
        axs[i_row, i_col].scatter(data_use[variable_name], 
                                  data_use[variable_name+'_shap'], alpha=0.05,
                                  marker = '.', linewidths=0)
        axs[i_row, i_col].grid(True)
        axs[i_row, i_col].text(text_x, text_y, month, fontsize=20, weight='bold', color='r')
        axs[i_row, i_col].set_xlabel('Temperature', fontsize=15)
        axs[i_row, i_col].set_ylabel('Temperature' + ' SHAP', fontsize=15)
    plt.show(); 
    fig.savefig(REPO_FIGURE_LOCATION + "Monthly_Temperature_Shap.jpg", bbox_inches='tight')
    return None

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('y')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    REPO_FIGURE_LOCATION = REPO_LOCATION + '11_Figure0618/'
    Dataset_Shap_Df = getShapDf() ### -> easy
    plotValueShap(Dataset_Shap_Df)
    
    run=False
    if run:
        Dataset_Shap_Df1 = getShapDf1()
        plotValueShap1(Dataset_Shap_Df1)
    
    
    #plotTempShapMonthly(Dataset_Shap_Df)
    
    
    