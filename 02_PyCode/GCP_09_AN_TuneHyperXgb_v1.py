# -*- coding: utf-8 -*-
"""
Created on Tue May 23 16:45:32 2023

@author: Li Chao

for GCP
"""

import pandas as pd
import pyreadr
from shap import TreeExplainer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import xgboost as xgb

def getXandStanY():
    result = pyreadr.read_r(REPO_LOCATION + "99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df = df.drop(columns=['TimeVariable', 'PrefID'])
    df.set_index(['GridID', 'time'], inplace=True)
    df = df[['lowSpeedDensity', 'Temperature', 'NTL',
             'ter_pressure', 'NDVI', 'humidity', 'precipitation', 
             'speedwind', 'mg_m2_troposphere_no2', 'ozone',
             'UVAerosolIndex', 'PBLH', 'prevalance', 'mortality',
             'emergence', 'year', 'month']]
    X = df.iloc[:,1:df.shape[1]].copy()
    y = df.iloc[:,0:1].copy()
    y_stan = y.reset_index()
    mean_y = y_stan.groupby('GridID')['lowSpeedDensity'].mean().to_frame().rename(columns={'lowSpeedDensity': 'mean'}).reset_index()
    std_y = y_stan.groupby('GridID')['lowSpeedDensity'].std().to_frame().rename(columns={'lowSpeedDensity': 'std'}).reset_index()
    merge_y = y_stan.merge(mean_y, on='GridID', how='left')
    merge_y = merge_y.merge(std_y, on='GridID', how='left')
    merge_y['stan_y'] = (merge_y['lowSpeedDensity'] - merge_y['mean'])/ merge_y['std']
    merge_y.set_index(['GridID', 'time'], inplace=True)
    merge_y = merge_y[['stan_y']]
    return df, X, merge_y

def tuningHyperNestimator(X, y, n_estimators_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for n_estimators in n_estimators_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {n_estimators}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = n_estimators
    return best_score, best_parameter

def tuningHyperLr(X, y, n_estimators, learning_rate_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in learning_rate_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def tuningHyperMaxDepth(X, y, n_estimators, learning_rate,
                        tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

REPO_LOCATION = "/home/gcp_cpu/DP11/"
REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'

df, X, y = getXandStanY()
best_score, best_n_estimators = tuningHyperNestimator(X, y, 
                                                      [100, 200, 300, 400, 500,
                                                       600, 700, 800, 900, 1000,
                                                       1100, 1200, 1300, 1400,
                                                       1500, 1600, 1700, 1800,
                                                       1900, 2000, 2100, 2200, 
                                                       2300, 2400, 2500, 2600,
                                                       2700, 2800, 2900, 3000])
### n_estimators = 3000
best_score, best_lr = tuningHyperLr(X, y, 3000, 
                                    [0.01, 0.05, 0.1, 0.2, 0.5, 0.6, 0.8])

### learning_rate = 0.5
best_score, best_maxdepth = tuningHyperMaxDepth(X, y, 3000, 0.5,
                                                [3, 4, 5, 6, 7, 8, 9, 10,
                                                 11, 12, 13, 14, 15])

