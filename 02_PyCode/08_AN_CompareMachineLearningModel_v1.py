# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 12:33:40 2023

@author: Li Chao
"""

import pandas as pd
import pyreadr
from sklearn.ensemble import AdaBoostRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import r2_score
from sklearn.tree import DecisionTreeRegressor
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

def TestModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    
    xgmodel = xgb.XGBRegressor(n_estimators=100, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"xg Accuracy: {xgaccuracy:.4f}")

    
    rfmodel = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf Accuracy: {rfaccuracy:.4f}")
    
    base_estimator = DecisionTreeRegressor(max_depth=1)
    adamodel = AdaBoostRegressor(base_estimator=base_estimator, n_estimators=100, 
                                  learning_rate=0.1, random_state=42)
    adamodel.fit(X_train, y_train)
    y_pred = adamodel.predict(X_test)
    adaaccuracy = r2_score(y_test, y_pred)
    print(f"ada Accuracy: {adaaccuracy:.4f}")

    
    olsmodel = LinearRegression()
    olsmodel.fit(X_train, y_train)
    y_pred = olsmodel.predict(X_test)
    olsaccuracy = r2_score(y_test, y_pred)
    print(f"ols Accuracy: {olsaccuracy:.4f}")
    return xgaccuracy, rfaccuracy, adaaccuracy, olsaccuracy

def testRfModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    
    rfmodel = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=9)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf 100 trees Accuracy: {rfaccuracy:.4f}")
    
    rfmodel = RandomForestRegressor(n_estimators=500, random_state=42, n_jobs=9)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf 500 trees Accuracy: {rfaccuracy:.4f}")
    
    rfmodel = RandomForestRegressor(n_estimators=1000, random_state=42, n_jobs=9)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf 1000 trees Accuracy: {rfaccuracy:.4f}")
    
    return None

def testXgbModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.1, 
                                                        random_state=42) 
    
    xgmodel = xgb.XGBRegressor(n_estimators=100, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"100 xg Accuracy: {xgaccuracy:.4f}")
    
    xgmodel = xgb.XGBRegressor(n_estimators=200, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"200 xg Accuracy: {xgaccuracy:.4f}")
    
    xgmodel = xgb.XGBRegressor(n_estimators=300, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"300 xg Accuracy: {xgaccuracy:.4f}")
    
    xgmodel = xgb.XGBRegressor(n_estimators=400, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"400 xg Accuracy: {xgaccuracy:.4f}")
    
    xgmodel = xgb.XGBRegressor(n_estimators=500, learning_rate=0.1, max_depth=10,
                               seed=42, n_jobs=-1) 
    xgmodel.fit(X_train, y_train)
    y_pred = xgmodel.predict(X_test)
    xgaccuracy = r2_score(y_test, y_pred)
    print(f"500 xg Accuracy: {xgaccuracy:.4f}")
    
    return None
    

REPO_LOCATION = runLocallyOrRemotely('y')

df, X, y = getXandY()

TestModel(X, y)
#testRfModel(X, y)
testXgbModel(X, y)

