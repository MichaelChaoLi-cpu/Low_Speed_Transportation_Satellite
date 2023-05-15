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

def getBestModel(X, y, *args, **kwargs):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    xgb_regressor = xgb.XGBRegressor(**kwargs)
    xgb_regressor.fit(X_train, y_train)
    y_pred = xgb_regressor.predict(X_test)
    accuracy = r2_score(y_test, y_pred)
    print(f"CV; Accuracy: {accuracy*100:.2f}%")
    xgb_regressor = xgb.XGBRegressor()
    xgb_regressor.fit(X, y)
    y_pred = xgb_regressor.predict(X)
    accuracy = r2_score(y, y_pred)    
    print(f"ALL; Accuracy: {accuracy*100:.2f}%")
    return xgb_regressor

def getShap(model, X_test):
    explainer = TreeExplainer(model)
    shap_value = explainer.shap_values(X_test, check_additivity=False)
    return shap_value

def makeDatasetWithShap(df, shap_value):
    X_colname = df.columns
    X_colname = X_colname[1:]
    shap_colnames = X_colname + "_shap"
    df.reset_index(inplace=True)
    shap_value.columns = shap_colnames
    dataset_to_analysis = pd.concat([df, shap_value], axis=1)
    return dataset_to_analysis

REPO_LOCATION = runLocallyOrRemotely('y')
REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'

if __name__ == '__main__':
    df, X, y = getXandYinFirstDifference()
    model = getBestModel(X, y, n_jobs=-1, n_estimators = 500, learning_rate = 0.5,
                         max_depth = 9, min_child_weight = 5, gamma = 0, 
                         subsample = 1, colsample_bytree = 1, reg_alpha = 0.5,
                         reg_lambda = 0.9)
    shap_value = getShap(model, X)
    
    dump(shap_value, REPO_RESULT_LOCATION + '03_TreeShapFirstDifference.joblib') 
    shap_value = pd.DataFrame(shap_value)
    
    dataset_to_analysis = makeDatasetWithShap(df, shap_value)
    dataset_to_analysis.to_csv(REPO_RESULT_LOCATION + 'mergedXSHAP.csv', index=False)  








