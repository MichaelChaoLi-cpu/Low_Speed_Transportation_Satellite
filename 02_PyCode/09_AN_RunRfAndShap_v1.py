#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 22 16:37:10 2023

@author: lichao
"""

import pandas as pd
import pyreadr
from shap import TreeExplainer
import shap
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

def getXandY():
    result = pyreadr.read_r(REPO_LOCATION + "04_Data/99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df.set_index(['GridID', 'time'], inplace=True)
    df = df.drop(columns=['TimeVariable', 'PrefID'])
    X = df.iloc[:,1:df.shape[1]].copy()
    y = df.iloc[:,0:1].copy()
    return df, X, y

def getBestMaxDepthModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    good_accuracy = 0
    good_max_depth = 0
    for now_depth in list(range(10, 30, 1)):
        rfmodel = RandomForestRegressor(n_estimators=100, random_state=42, 
                                        n_jobs=-1, max_depth=now_depth)
        rfmodel.fit(X_train, y_train)
        y_pred = rfmodel.predict(X_test)
        rfaccuracy = r2_score(y_test, y_pred)
        print(f"depth {now_depth}, rf Accuracy: {rfaccuracy:.4f}")
        if rfaccuracy > good_accuracy:
            good_accuracy = rfaccuracy
            good_max_depth = now_depth
    
    return good_max_depth

def trainBestModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    
    rfmodel = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1,
                                    max_depth=14)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf Accuracy: {rfaccuracy:.4f}")
    
    return rfmodel, X_train, X_test, y_train, y_test
    
def getShap(model, X_test):
    explainer = TreeExplainer(model)
    shap_value = explainer.shap_values(X_test)
    return shap_value

def getShapTree(model, X):
    explainer = shap.explainers.Tree(model)
    shap_value = explainer.shap_values(X)
    return shap_value

def getShapKernel(model, X, y):
    _, X_use, _, _ = train_test_split(X, y, test_size=1000, random_state=42)
    explainer = shap.KernelExplainer(model.predict, X_use)
    shap_value = explainer.shap_values(X)
    return shap_value

REPO_LOCATION = "D:/OneDrive - Kyushu University/11_Article/03_RStudio/"

df, X, y = getXandY()
good_max_depth = getBestMaxDepthModel(X, y)
rfmodel, X_train, X_test, y_train, y_test = trainBestModel(X, y)
#shap_value = getShap(rfmodel, X)
shap_value_tree = getShapTree(rfmodel, X.iloc[0:10,:])
#shap_value_kernel = getShapKernel(rfmodel, X, y)



"""
REPO_LOCATION = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/11_Article/03_RStudio/"
"""



