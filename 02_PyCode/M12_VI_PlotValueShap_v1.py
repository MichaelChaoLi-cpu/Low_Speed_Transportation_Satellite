#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 19 15:00:09 2023

@author: lichao
"""

from M11_AN_RunXgbAndShap_v1 import runLocallyOrRemotely

from joblib import load
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

def getShapDf():
    dataset_to_analysis = pd.read_csv(REPO_RESULT_LOCATION + '03_mergedXSHAPStdize_noah_withoutAP.csv')
    dataset_to_analysis = dataset_to_analysis.set_index(['GridID', 'time'])
    return dataset_to_analysis


def plotValueShap(Dataset_Shap_Df, Figure_Name = "All_SHAP.jpg"):
    #variable_of_interest = list(Dataset_Shap_Df.columns[1:19])
    
    X_colname = ['tair', 'psurf', 'qair', 'wind', 'rainf', 
                 'NTL', 'NDVI', 'PBLH', 
                 'prevalance', 'mortality', 'emergence',  
                 'x', 'y'
                 ]
    sub_order = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
                 'l', 'm', 
                 ]
    feature_name = ["Temperature", "Air Pressure", "Humidity", "Wind Speed", 
                    "Precipitation", "NTL", "NDVI", 
                    "PBLH", "Prevalence",
                    "Mortality", "Emergence", 
                    "Longitude", "Latitude"]
    fig, axs = plt.subplots(nrows=4, ncols=4, figsize=(29.7, 21), dpi=300)
    for i, variable_name in enumerate(X_colname):
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
    fig.savefig(REPO_FIGURE_LOCATION + Figure_Name, bbox_inches='tight')
    return None

def getMeanGridY():
    df_raw = pd.read_csv(REPO_DATA_LOCATION + "98_DatasetWithNoah.csv")
    mean_y_df = df_raw.groupby('GridID')['lowSpeedDensity'].mean().reset_index()
    return mean_y_df

def plotImportanct(Filename = '03_importance_noah_withoutAP.joblib'):
    importance = load(REPO_RESULT_LOCATION + Filename)
    # Convert your importance dictionary to lists for plotting
    features = list(importance.keys())
    features = features[-5:] + features[0:8]
    importance_values = list(importance.values())
    importance_values = importance_values[-5:] + importance_values[0:8]
    features = ['Temperature', "Air Pressure", "Humidity",
                'Wind Speed', 'Precipitation', 'NTL',
                "NDVI", "PBLH", 'Prevalance', 'Mortality',
                'Emergence', 'Longitude', 'Latitude'
                ]
    
    # Create a new figure and plot the data
    plt.figure(figsize=(10, 6))
    plt.barh(features, importance_values, color='skyblue')
    plt.xlabel('Importance')
    plt.ylabel('Features')
    plt.title('Feature Importance')
    plt.gca().invert_yaxis()
    plt.savefig(REPO_FIGURE_LOCATION + 'Importance.jpg', format='jpeg', dpi=300)
    plt.show()
    return None

    

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('y')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    REPO_FIGURE_LOCATION = REPO_LOCATION + '11_Figure0618/'
    REPO_DATA_LOCATION = REPO_LOCATION + '04_Data/'
    Dataset_Shap_Df = getShapDf() ### -> easy
    plotValueShap(Dataset_Shap_Df, "All_SHAP.jpg")

    mean_y_df = getMeanGridY()
    mean_y_df_busy = mean_y_df[mean_y_df['lowSpeedDensity']>600000]
    Dataset_Shap_Df_busy = Dataset_Shap_Df.reset_index()
    Dataset_Shap_Df_busy = Dataset_Shap_Df_busy[Dataset_Shap_Df_busy.GridID.isin(mean_y_df_busy.GridID)]
    plotValueShap(Dataset_Shap_Df_busy, "Busy_SHAP.jpg")
    
    #plotTempShapMonthly(Dataset_Shap_Df)
    
    
    