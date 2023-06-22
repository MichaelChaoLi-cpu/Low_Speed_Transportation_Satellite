# -*- coding: utf-8 -*-
"""
Created on Tue May 23 16:45:32 2023

@author: Li Chao

for GCP
"""

from joblib import dump
import os
import pandas as pd
import pyreadr
from shap import TreeExplainer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import xgboost as xgb

def getXandStanY():
    result = pyreadr.read_r(REPO_LOCATION + "04_Data/99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df = df.drop(columns=['TimeVariable', 'PrefID'])
    df.set_index(['GridID', 'time'], inplace=True)
    df = df[['lowSpeedDensity', 'Temperature', 'NTL',
             'ter_pressure', 'NDVI', 'humidity', 'precipitation', 
             'speedwind', 'mg_m2_troposphere_no2', 'ozone',
             'UVAerosolIndex', 'PBLH', 'prevalance', 'mortality',
             'emergence', 'year', 'month', 'x', 'y']]
    X = df.iloc[:,1:df.shape[1]].copy()
    y = df.iloc[:,0:1].copy()
    y_stan = y.reset_index()
    mean_y = y_stan.groupby('GridID')['lowSpeedDensity'].mean().to_frame().rename(columns={'lowSpeedDensity': 'mean'}).reset_index()
    std_y = y_stan.groupby('GridID')['lowSpeedDensity'].std().to_frame().rename(columns={'lowSpeedDensity': 'std'}).reset_index()
    merge_y = y_stan.merge(mean_y, on='GridID', how='left')
    merge_y = merge_y.merge(std_y, on='GridID', how='left')
    merge_y['stan_y'] = (merge_y['lowSpeedDensity'] - merge_y['mean'])/ merge_y['std']
    merge_y.set_index(['GridID', 'time'], inplace=True)
    y_output = merge_y[['stan_y']]
    df = pd.concat([X, merge_y], axis=1)
    return df, X, y_output

def getXandStanYnoah():
    df = pd.read_csv(REPO_LOCATION + "98_DatasetWithNoah.csv", index_col=0)
    df.set_index(['GridID', 'time'], inplace=True)
    df = df.drop(columns=['year', 'month'])
    df.dropna(inplace=True)
    df_output = df.copy()
    aim_variable_list = ['lowSpeedDensity',  
                         'tair', 'psurf', 'qair', 'wind', 'rainf',
                         'NTL', 'NDVI', 
                         'UVAerosolIndex', 'PBLH']
    for variable_name in aim_variable_list:
        df_output[variable_name] = df_output.groupby('GridID')[variable_name].transform(lambda x: (x - x.mean()) / x.std())
    
    X = df_output.iloc[:,1:df.shape[1]].copy()
    y = df_output.iloc[:,0:1].copy()

    return df_output, X, y

def tuningHyperNestimator(X, y, n_estimators_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for n_estimators in n_estimators_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',)
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
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

def tuningHyperChild(X, y, n_estimators, learning_rate, max_depth,
                     tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth,
                                         min_child_weight = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def tuningHyperGamma(X, y, n_estimators, learning_rate, max_depth, min_child_weight,
                     tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, 
                                         min_child_weight = min_child_weight,
                                         gamma = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def tuningHyperSubsample(X, y, n_estimators, learning_rate, 
                         max_depth, min_child_weight, gamma,
                         tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, 
                                         min_child_weight = min_child_weight,
                                         gamma = gamma, subsample = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter


def tuningHypercolsample_bytree(X, y, n_estimators, learning_rate, 
                                max_depth, min_child_weight, gamma,
                                subsample,
                                tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators,
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, 
                                         min_child_weight = min_child_weight,
                                         gamma = gamma, subsample = subsample,
                                         colsample_bytree = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def tuningHyperreg_alpha(X, y, n_estimators, learning_rate, 
                                max_depth, min_child_weight, gamma,
                                subsample, colsample_bytree,
                                tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, 
                                         min_child_weight = min_child_weight,
                                         gamma = gamma, subsample = subsample,
                                         colsample_bytree = colsample_bytree,
                                         reg_alpha = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def tuningHyperreg_lambda(X, y, n_estimators, learning_rate, 
                                max_depth, min_child_weight, gamma,
                                subsample, colsample_bytree, reg_alpha,
                                tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, 
                                         tree_method='gpu_hist',
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, 
                                         min_child_weight = min_child_weight,
                                         gamma = gamma, subsample = subsample,
                                         colsample_bytree = colsample_bytree,
                                         reg_alpha = reg_alpha,
                                         reg_lambda = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

def testBestModel(X, y, *args, **kwargs):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    xgb_regressor = xgb.XGBRegressor(**kwargs)
    xgb_regressor.fit(X_train, y_train)
    y_pred = xgb_regressor.predict(X_test)
    accuracy = r2_score(y_test, y_pred)
    print(f"CV; Accuracy: {accuracy*100:.2f}%")
    xgb_regressor = xgb.XGBRegressor(**kwargs)
    xgb_regressor.fit(X, y)
    y_pred = xgb_regressor.predict(X)
    accuracy = r2_score(y, y_pred)    
    print(f"ALL; Accuracy: {accuracy*100:.2f}%")
    return xgb_regressor

def getShap(model, X):
    explainer = TreeExplainer(model)
    shap_value = explainer.shap_values(X, check_additivity=False)
    return shap_value

def makeDatasetWithShap(df, shap_value_input):
    shap_value = shap_value_input.copy()
    index_df = df.reset_index()[['GridID', 'time']]
    shap_value = pd.concat([index_df, shap_value], axis=1).set_index(['GridID', 'time'])
    X_colname = df.columns[1:]
    shap_colnames = X_colname + "_shap"
    shap_value.columns = shap_colnames
    dataset_to_analysis = pd.concat([df, shap_value], axis=1)
    return dataset_to_analysis

REPO_LOCATION = os.getcwd() + '/'
REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'

df, X, y = getXandStanYnoah()
best_score, best_n_estimators = tuningHyperNestimator(X, y, 
                                                      [100, 200, 300, 400, 500,
                                                       600, 700, 800, 900, 1000,
                                                       1100, 1200, 1300, 1400,
                                                       1500, 1600, 1700, 1800,
                                                       1900, 2000, 2100, 2200, 
                                                       2300, 2400, 2500, 2600,
                                                       2700, 2800, 2900, 3000])
### n_estimators = 3000
best_score, best_lr = tuningHyperLr(X, y, best_n_estimators, 
                                    [0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 
                                     0.5, 0.6, 0.7, 0.8])

### learning_rate = 0.3
best_score, best_maxdepth = tuningHyperMaxDepth(X, y, best_n_estimators, best_lr,
                                                [3, 4, 5, 6, 7, 8, 9, 10,
                                                 11, 12, 13, 14, 15, 16, 17,
                                                 18, 19, 20, 21, 22, 23, 24,
                                                 25])
### max_depth = 18
best_score, best_child = tuningHyperChild(X, y, best_n_estimators, best_lr, 
                                          best_maxdepth, 
                                          [1, 2, 3, 4, 5, 
                                           6, 7, 8, 9, 10])
### min_child_weight=2
best_score, best_gamma = tuningHyperGamma(X, y, best_n_estimators, best_lr,
                                          best_maxdepth, best_child,
                                             [0, 1, 2, 3, 4, 5])
### gamma = 0
best_score, best_Subsample = tuningHyperSubsample(X, y, best_n_estimators, best_lr,
                                                  best_maxdepth, best_child,
                                                  best_gamma, 
                                                  [0.5, 0.6, 0.7, 0.8, 0.9, 1])
### subsample = 1
best_score, best_colsample_bytree = tuningHypercolsample_bytree(X, y, best_n_estimators, best_lr,
                                                                best_maxdepth, best_child,
                                                                best_gamma, best_Subsample,
                                                                [0.1, 0.2, 0.3, 0.4, 0.5,
                                                                 0.6, 0.7, 0.8, 0.9, 1])
### colsample_bytree = 0.5
best_score, best_reg_alpha = tuningHyperreg_alpha(X, y, best_n_estimators, best_lr, 
                                                  best_maxdepth, best_child,
                                                  best_gamma, best_Subsample,
                                                  best_colsample_bytree,
                                                  [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                   0.6, 0.7, 0.8, 0.9, 1])
### reg_alpha = 0.5
best_score, best_reg_lambda = tuningHyperreg_lambda(X, y, best_n_estimators, best_lr, 
                                                    best_maxdepth, best_child,
                                                    best_gamma, best_Subsample, 
                                                    best_colsample_bytree, best_reg_alpha,
                                                    [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                     0.6, 0.7, 0.8, 0.9, 1])
### reg_lambda = 1

model = testBestModel(X, y, tree_method='gpu_hist', 
                      n_estimators = best_n_estimators, learning_rate = best_lr,
                      max_depth = best_maxdepth, min_child_weight = best_child, 
                      gamma = best_gamma, subsample = best_Subsample, 
                      colsample_bytree = best_colsample_bytree, reg_alpha = best_reg_alpha,
                      reg_lambda = best_reg_lambda)

shap_value = getShap(model, X)

dump(shap_value, REPO_RESULT_LOCATION + '03_TreeShapFirstDifference_noah.joblib') 
shap_value = pd.DataFrame(shap_value)

dataset_to_analysis = makeDatasetWithShap(df, shap_value)
dataset_to_analysis.to_csv(REPO_RESULT_LOCATION + 'mergedXSHAP_noah.csv') 
