#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 22 16:37:10 2023

@author: lichao
"""

from joblib import dump
import pandas as pd
import pyreadr
from shap import TreeExplainer
import shap
from sklearn.ensemble import RandomForestRegressor
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

def getXandY():
    result = pyreadr.read_r(REPO_LOCATION + "04_Data/99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df.set_index(['GridID', 'time'], inplace=True)
    df = df.drop(columns=['TimeVariable', 'PrefID'])
    X = df.iloc[:,1:df.shape[1]].copy()
    y = df.iloc[:,0:1].copy()
    return df, X, y


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
    
    return xgmodel, X_train, X_test, y_train, y_test
    
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

REPO_LOCATION = runLocallyOrRemotely('y')
REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'

df, X, y = getXandY()

model, X_train, X_test, y_train, y_test = trainBestModel(X, y)
shap_value = getShap(model, X)
#shap_value_tree = getShapTree(model, X.iloc[0:10,:])
#shap_value_kernel = getShapKernel(rfmodel, X, y)

dump(shap_value, REPO_RESULT_LOCATION + '02_TreeShap.joblib')      

"""
REPO_LOCATION = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/11_Article/03_RStudio/"
"""



