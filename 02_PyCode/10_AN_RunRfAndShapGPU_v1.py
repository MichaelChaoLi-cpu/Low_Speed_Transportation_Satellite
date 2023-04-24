#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 23 15:13:01 2023

@author: lichao
"""

import cudf
from cuml.ensemble import RandomForestRegressor as cuRandomForestRegressor
from cuml.explainer import KernelExplainer
from cuml.explainer import TreeExplainer
from joblib import dump, load
import numpy as np
import pandas as pd
import pyreadr
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split


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

def makeCuModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, 
                                                        random_state=42)
    X_train = cudf.DataFrame.from_pandas(pd.DataFrame(X_train))
    X_test = cudf.DataFrame.from_pandas(pd.DataFrame(X_test))
    y_train = cudf.DataFrame.from_pandas(pd.DataFrame(y_train))
    y_test = cudf.DataFrame.from_pandas(pd.DataFrame(y_test))
    cumodel = cuRandomForestRegressor(n_estimators=100, random_state=42, max_depth = 30)
    cumodel.fit(X_train, y_train)
    y_pred = cumodel.predict(X_test)
    r2 = r2_score(y_test.to_pandas(), y_pred.to_pandas())
    print(f"R^2 score: {r2:.4f}")

    cuX = cudf.from_pandas(X)
    cuy = cudf.from_pandas(y)
    cumodel = cuRandomForestRegressor(n_estimators=100, random_state=42, max_depth = 30)
    cumodel.fit(cuX, cuy) 
    return cumodel

def getExplainer(X, y, cumodel):
    _, X_use, _, _ = train_test_split(X, y, test_size=1000, random_state=42)
    cuX_use = cudf.DataFrame.from_pandas(pd.DataFrame(X_use))
    cu_explainer = KernelExplainer(model=cumodel.predict,
                                   data=cuX_use,
                                   is_gpu_model=True, random_state=42)
    return cu_explainer

def getShapValue(Cu_Explainer, X, Current_Fold=None):
    if Current_Fold:
        shap_dataset = load(REPO_RESULT_LOCATION + '01_ShapDataset.joblib')
        print(f"from the {Current_Fold*1000} data, now shap_dataset shape is {shap_dataset.shape}")
    else:
        shap_dataset = np.empty((0, 18))
        Current_Fold = 0
        print(f"from the first data, now shap_dataset shape is {shap_dataset.shape}")
    for fold in list(range(Current_Fold, X.shape[0]//1000)):
        print(f'this is the {fold}, data covers {fold*1000} to {(fold+1)*1000} in {X.shape[0]}')
        X_toshap = X.iloc[fold*1000:(fold+1)*1000,:]
        shap_this_fold = Cu_Explainer.shap_values(X_toshap)
        shap_dataset = np.concatenate((shap_dataset, shap_this_fold), axis=0)
        dump(shap_dataset, REPO_RESULT_LOCATION + '01_ShapDataset.joblib')      
    return shap_dataset

REPO_LOCATION = runLocallyOrRemotely('wsl')
REPO_RESULT_LOCATION = REPO_LOCATION + '03_Results/'
df, X, y = getXandY()
cumodel = makeCuModel(X, y)
Cu_Explainer = getExplainer(X, y, cumodel)
Shap_Dataset = getShapValue(Cu_Explainer, X)
