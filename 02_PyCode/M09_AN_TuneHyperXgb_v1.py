# -*- coding: utf-8 -*-
"""
Created on Mon May  8 13:56:41 2023

@author: Li Chao
"""

from M11_AN_RunXgbAndShap_v1 import runLocallyOrRemotely
from M11_AN_RunXgbAndShap_v1 import getXandYinFirstDifference

import pandas as pd
import pyreadr
from shap import TreeExplainer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import xgboost as xgb

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

def tuningHyperChild(X, y, n_estimators, learning_rate, max_depth,
                     tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, min_child_weight = 5,
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, min_child_weight = 5,
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, min_child_weight = 5,
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, min_child_weight = 5,
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
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, min_child_weight = 5,
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
    xgb_regressor = xgb.XGBRegressor()
    xgb_regressor.fit(X, y)
    y_pred = xgb_regressor.predict(X)
    accuracy = r2_score(y, y_pred)    
    print(f"ALL; Accuracy: {accuracy*100:.2f}%")
    return None

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('y')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    df, X, y = getXandYinFirstDifference()
    
    run = False
    if run:
        best_score, best_n_estimators = tuningHyperNestimator(X, y, 
                                                              [100, 200, 300, 400, 500,
                                                               600, 700, 800, 900, 1000])
        ### n_estimators = 500
        best_score, best_lr = tuningHyperLr(X, y, 500, 
                                            [0.01, 0.05, 0.1, 0.2, 0.5, 0.6, 0.8])
        ### learning_rate = 0.5
        best_score, best_maxdepth = tuningHyperMaxDepth(X, y, 500, 0.5,
                                                        [3, 4, 5, 6, 7, 8, 9, 10,
                                                         11, 12, 13, 14, 15])
        ### max_depth = 9
        best_score, best_child = tuningHyperChild(X, y, 500, 0.5, 9, 
                                                  [1, 2, 3, 4, 5, 
                                                   6, 7, 8, 9, 10])
        ### min_child_weight = 5
        best_score, best_gamma = tuningHyperGamma(X, y, 500, 0.5, 9, 5,
                                                     [0, 1, 2, 3, 4, 5])
        ### gamma = 0
        best_score, best_Subsample = tuningHyperSubsample(X, y, 500, 0.5, 9, 5,
                                                          0, 
                                                          [0.5, 0.6, 0.7, 0.8, 0.9, 1])
        ### subsample = 1
        best_score, best_colsample_bytree = tuningHypercolsample_bytree(X, y, 500, 0.5, 9, 5,
                                                          0, 1,
                                                          [0.1, 0.2, 0.3, 0.4, 0.5,
                                                           0.6, 0.7, 0.8, 0.9, 1])
        ### colsample_bytree = 1
        best_score, best_reg_alpha = tuningHyperreg_alpha(X, y, 500, 0.5, 9, 5,
                                                          0, 1, 1, 
                                                          [0.1, 0.2, 0.3, 0.4, 0.5,
                                                           0.6, 0.7, 0.8, 0.9, 1])
        ### reg_alpha = 0.5
        best_score, best_reg_lambda = tuningHyperreg_lambda(X, y, 500, 0.5, 9, 5,
                                                          0, 1, 1, 0.5,
                                                          [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                           0.6, 0.7, 0.8, 0.9, 1])        
        ### reg_lambda = 0.9
        
    testBestModel(X, y, n_jobs=-1, n_estimators = 500, learning_rate = 0.5,
                  max_depth = 9, min_child_weight = 5, gamma = 0, 
                  subsample = 1, colsample_bytree = 1, reg_alpha = 0.5,
                  reg_lambda = 0.9)
    