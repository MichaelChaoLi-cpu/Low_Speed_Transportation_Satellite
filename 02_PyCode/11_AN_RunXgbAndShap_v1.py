# -*- coding: utf-8 -*-
"""
Created on Wed Apr 26 11:28:48 2023

@author: chaol
"""

from joblib import dump
import pandas as pd
import pyreadr
from shap import TreeExplainer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import xgboost as xgb

def runLocallyOrRemotely(Locally_Or_Remotely):
    locally_or_remotely = Locally_Or_Remotely
    if locally_or_remotely == 'y':
        repo_location = "D:/OneDrive - Kyushu University/11_Article/03_RStudio/"
    elif locally_or_remotely == 'n':
        repo_location = "/home/usr6/q70176a/DP11/"
    elif locally_or_remotely == 'wsl':
        repo_location = "/mnt/d/OneDrive - Kyushu University/11_Article/03_RStudio/"
    elif  locally_or_remotely == 'linux':
        repo_location = "/mnt/d/OneDrive - Kyushu University/11_Article/03_RStudio/"
    return repo_location

def getXandYinFirstDifference():
    result = pyreadr.read_r(REPO_LOCATION + "04_Data/99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df = df.drop(columns=['TimeVariable', 'PrefID'])
    location_dataset = df[['GridID', 'time', 'x', 'y']]
    location_dataset.set_index(['GridID', 'time'], inplace=True)
    df_to_firstdifference = df[['GridID', 'lowSpeedDensity', 'Temperature', 'NTL',
                                'ter_pressure', 'NDVI', 'humidity', 'precipitation', 
                                'speedwind', 'mg_m2_troposphere_no2', 'ozone',
                                'UVAerosolIndex', 'PBLH', 'prevalance', 'mortality',
                                'emergence', 'time']]
    df_to_firstdifference.set_index(['GridID'], inplace=True)
    df_diffencemerge = pd.DataFrame(columns=df_to_firstdifference.columns)
    time_stamp = [201901, 201902, 201903, 201904, 201905, 201906,
                  201907, 201908, 201909, 201910, 201911, 201912,
                  202001, 202002, 202003, 202004, 202005, 202006,
                  202007, 202008, 202009, 202010, 202011, 202012
                  ]
    for i, time_index in enumerate(time_stamp[:-1]):
        df_before = df_to_firstdifference[df_to_firstdifference['time'] == time_index]
        df_after = df_to_firstdifference[df_to_firstdifference['time'] == time_stamp[i+1]]
        df_difference = df_after - df_before
        df_difference['time'] =  time_index
        df_diffencemerge = pd.concat([df_diffencemerge, df_difference])
    df_diffencemerge.index.name = 'GridID'
    df_diffencemerge.reset_index(inplace=True)
    df_diffencemerge.set_index(['GridID', 'time'], inplace=True)
    df_diffencemerge = pd.concat([df_diffencemerge, location_dataset], axis=1)
    df_diffencemerge = df_diffencemerge.dropna()
    X = df_diffencemerge.iloc[:,1:df_diffencemerge.shape[1]].copy()
    y = df_diffencemerge.iloc[:,0:1].copy()
    return df_diffencemerge, X, y

def trainBestModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    
    xgmodel = xgb.XGBRegressor(n_estimators=100, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"100 xg Accuracy: {xgaccuracy:.4f}")
    
    print("model should be full size, so all data are in")
    xgmodel.fit(X, y)
    return xgmodel

def getShap(model, X_test):
    explainer = TreeExplainer(model)
    shap_value = explainer.shap_values(X_test, check_additivity=False)
    return shap_value

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('y')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    df, X, y = getXandYinFirstDifference()
    model = trainBestModel(X, y)
    shap_value = getShap(model, X)
    
    dump(shap_value, REPO_RESULT_LOCATION + '03_TreeShapFirstDifference.joblib')      








