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

def tuningHyperGamma(X, y, n_estimators, learning_rate, max_depth,
                     tuning_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    for interest in tuning_list:
        xgb_regressor = xgb.XGBRegressor(n_estimators = n_estimators, n_jobs=-1,
                                         learning_rate = learning_rate, 
                                         max_depth = max_depth, gamma = interest)
        xgb_regressor.fit(X_train, y_train)
        y_pred = xgb_regressor.predict(X_test)
        accuracy = r2_score(y_test, y_pred)
        print(f"Parameter: {interest}; Accuracy: {accuracy*100:.2f}%")
        if accuracy > best_score:
            best_score = accuracy
            best_parameter = interest
    return best_score, best_parameter

if __name__ == '__main__':
    REPO_LOCATION = runLocallyOrRemotely('y')
    REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
    df, X, y = getXandYinFirstDifference()
    best_score, best_n_estimators = tuningHyperNestimator(X, y, 
                                                          [100, 200, 300, 400, 500,
                                                           600, 700, 800, 900, 1000])
    ### n_estimators = 500
    best_score, best_lr = tuningHyperLr(X, y, 500, 
                                        [0.01, 0.05, 0.1, 0.2, 0.5, 0.6, 0.8])
    ### lr = 0.5
    best_score, best_maxdepth = tuningHyperMaxDepth(X, y, 500, 0.5,
                                                    [3, 4, 5, 6, 7, 8, 9, 10,
                                                     11, 12, 13, 14, 15])
    ### max_depth = 9
    best_score, best_gamma = tuningHyperGamma(X, y, 500, 0.5, 9, 
                                                 [0, 1, 2, 3, 4, 5])