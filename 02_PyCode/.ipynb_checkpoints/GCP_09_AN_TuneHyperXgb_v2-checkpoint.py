# -*- coding: utf-8 -*-
"""
Created on Sun Jun 25 13:00:56 2023

@author: Li Chao
"""

from joblib import dump
import os
import pandas as pd
import pyreadr
from shap import TreeExplainer
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import xgboost as xgb

def compareModel(X, y):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    xgb_regressor = xgb.XGBRegressor(tree_method='gpu_hist')
    xgb_regressor.fit(X_train, y_train)
    y_pred = xgb_regressor.predict(X_test)
    accuracy = r2_score(y_test, y_pred)
    print(f"XGBoost; Accuracy: {accuracy*100:.2f}%")
    rfmodel = RandomForestRegressor(n_jobs=-1)
    rfmodel.fit(X_train, y_train)
    y_pred = rfmodel.predict(X_test)
    rfaccuracy = r2_score(y_test, y_pred)
    print(f"rf Accuracy: {rfaccuracy:.4f}")
    return None
    

def makeFinalDataset():
    result = pyreadr.read_r(REPO_DATA_LOCATION + "99_dataset_to_python.rds")
    df = pd.DataFrame(result[None])
    df['GridID'] = df['GridID'].astype('int64')
    df.set_index(['GridID', 'time'], inplace=True)
    df = df[['lowSpeedDensity', 'NTL', 'NDVI', 'PBLH', 
             'prevalance', 'mortality','emergence', 'x', 'y']]
    df_md = pd.read_csv(REPO_DATA_LOCATION + '18_AdditionalControlVariFromNoah0.1.csv')
    df_md.set_index(['GridID', 'time'], inplace=True)
    df_new = pd.concat([df, df_md], axis=1)
    df_new.dropna(inplace=True)
    df_new.to_csv(REPO_DATA_LOCATION + "98_DatasetWithNoah.csv")
    return df_new

def getXandStanYnoah():
    df = pd.read_csv(REPO_LOCATION + "98_DatasetWithNoah.csv")
    df.set_index(['GridID', 'time'], inplace=True)
    df.dropna(inplace=True)
    df_output = df.copy()
    aim_variable_list = ['lowSpeedDensity',  
                         'tair', 'psurf', 'qair', 'wind', 'rainf',
                         'NTL', 'NDVI', 'PBLH']
    for variable_name in aim_variable_list:
        df_output[variable_name] = df_output.groupby('GridID')[variable_name].transform(lambda x: (x - x.mean()) / x.std())
    
    X = df_output.iloc[:,1:df.shape[1]].copy()
    y = df_output.iloc[:,0:1].copy()

    return df_output, X, y

def getXandYnoahNormalize():
    df = pd.read_csv(REPO_LOCATION + "98_DatasetWithNoah.csv")
    df.set_index(['GridID', 'time'], inplace=True)
    df.dropna(inplace=True)
    df_output = df.copy()
    aim_variable_list = ['lowSpeedDensity',  
                         'tair', 'psurf', 'qair', 'wind', 'rainf',
                         'NTL', 'NDVI', 'PBLH']
    for variable_name in aim_variable_list:
        df_output[variable_name] = df_output.groupby('GridID')[variable_name].transform(lambda x: (x - x.min()) / (x.max()- x.min()))
    
    X = df_output.iloc[:,1:df.shape[1]].copy()
    y = df_output.iloc[:,0:1].copy()

    return df_output, X, y

def getXandYdiff():
    df = pd.read_csv(REPO_LOCATION + "98_DatasetWithNoah.csv", index_col=0)
    
    df.dropna(inplace=True)
    df_raw = df.copy()
    df_raw.set_index(['GridID'], inplace=True)
    df_raw = df_raw[[
        'time', 'lowSpeedDensity',  
        'tair', 'psurf', 'qair', 'wind', 'rainf',
        'NTL', 'NDVI', 'PBLH',
        'prevalance', 'mortality', 'emergence'
        ]]
    df_diffencemerge = pd.DataFrame(columns=df_raw.columns)
    
    time_stamp = [201901, 201902, 201903, 201904, 201905, 201906,
                  201907, 201908, 201909, 201910, 201911, 201912,
                  202001, 202002, 202003, 202004, 202005, 202006,
                  202007, 202008, 202009, 202010, 202011, 202012
                  ]
    for i, time_index in enumerate(time_stamp[:-1]):
        df_before = df_raw[df_raw['time'] == time_index]
        df_after = df_raw[df_raw['time'] == time_stamp[i+1]]
        df_difference = df_after - df_before
        df_difference['time'] =  time_index
        df_diffencemerge = pd.concat([df_diffencemerge, df_difference])
    df_diffencemerge.index.name = 'GridID'
    df_diffencemerge.reset_index(inplace=True)    
    df_diffencemerge.set_index(['GridID', 'time'], inplace=True)
    
    df_location = df[['GridID', 'time', 'x', 'y']].copy()
    df_location.set_index(['GridID', 'time'], inplace=True)
    df = pd.concat([df_diffencemerge, df_location], axis=1)
    
    df.dropna(inplace=True)
    df_output = df.copy()
    aim_variable_list = ['lowSpeedDensity',  
                         'tair', 'psurf', 'qair', 'wind', 'rainf',
                         'NTL', 'NDVI', 'PBLH']
    for variable_name in aim_variable_list:
        df_output[variable_name] = df_output.groupby('GridID')[variable_name].transform(lambda x: (x - x.mean()) / x.std())
    
    X = df_output.iloc[:,1:df.shape[1]].copy()
    y = df_output.iloc[:,0:1].copy()

    return df_output, X, y



#### tuning part
def tuningHyperNestimator(X, y, n_estimators_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
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
        tuning_list.append([n_estimators, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperLr(X, y, n_estimators, learning_rate_list):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperMaxDepth(X, y, n_estimators, learning_rate,
                        tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperChild(X, y, n_estimators, learning_rate, max_depth,
                     tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperGamma(X, y, n_estimators, learning_rate, max_depth, min_child_weight,
                     tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperSubsample(X, y, n_estimators, learning_rate, 
                         max_depth, min_child_weight, gamma,
                         tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list


def tuningHypercolsample_bytree(X, y, n_estimators, learning_rate, 
                                max_depth, min_child_weight, gamma,
                                subsample,
                                tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperreg_alpha(X, y, n_estimators, learning_rate, 
                         max_depth, min_child_weight, gamma,
                         subsample, colsample_bytree,
                         tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

def tuningHyperreg_lambda(X, y, n_estimators, learning_rate, 
                          max_depth, min_child_weight, gamma,
                          subsample, colsample_bytree, reg_alpha,
                          tuning_list_interest):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    best_score = 0
    best_parameter = 0
    tuning_list = []
    for interest in tuning_list_interest:
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
        tuning_list.append([interest, accuracy])
    return best_score, best_parameter, tuning_list

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
REPO_DATA_LOCATION = REPO_LOCATION + '04_Data/'

if __name__ == '__main__':
    model_compare = False
    if model_compare:
        df, X, y = getXandStanYnoah()
        
        print(X.columns)
        compareModel(X, y)
    
    
    run = False
    if run:
        df, X, y = getXandStanYnoah()
        
        print(X.columns)
        
        best_score, best_n_estimators, \
            tuning_n_estimator = tuningHyperNestimator(X, y, 
                                                        [100, 200, 300, 400, 500,
                                                         600, 700, 800, 900, 1000,
                                                         1100, 1200, 1300, 1400,
                                                         1500, 1600, 1700, 1800,
                                                         1900, 2000, 2100, 2200, 
                                                         2300, 2400, 2500, 2600,
                                                         2700, 2800, 2900, 3000])
        ### n_estimators = 3000
        best_score, best_lr, \
            tuning_lr = tuningHyperLr(X, y, best_n_estimators, 
                                      [0.01, 0.05, 0.1, 
                                       0.2, 0.3, 0.4, 
                                       0.5, 0.6, 0.7, 0.8])
        
        ### learning_rate = 0.3
        best_score, best_maxdepth, \
            tuning_maxdepth = tuningHyperMaxDepth(X, y, best_n_estimators, best_lr,
                                                  [3, 4, 5, 6, 7, 8, 9, 10,
                                                   11, 12, 13, 14, 15, 16, 17,
                                                   18, 19, 20, 21, 22, 23, 24,
                                                   25])
        ### max_depth = 18
        best_score, best_child, \
            tuning_child = tuningHyperChild(X, y, best_n_estimators, best_lr, 
                                            best_maxdepth, 
                                            [1, 2, 3, 4, 5, 
                                             6, 7, 8, 9, 10])
        ### min_child_weight=2
        best_score, best_gamma, \
            tuning_gamma = tuningHyperGamma(X, y, best_n_estimators, best_lr,
                                            best_maxdepth, best_child,
                                            [0, 1, 2, 3, 4, 5])
        ### gamma = 0
        best_score, best_Subsample, \
            tuning_Subsample = tuningHyperSubsample(X, y, best_n_estimators, best_lr,
                                                    best_maxdepth, best_child,
                                                    best_gamma, 
                                                    [0.5, 0.6, 0.7, 0.8, 0.9, 1])
        ### subsample = 1
        best_score, best_colsample_bytree, \
            tuning_bytree = tuningHypercolsample_bytree(X, y, best_n_estimators, best_lr,
                                                        best_maxdepth, best_child,
                                                        best_gamma, best_Subsample,
                                                        [0.1, 0.2, 0.3, 0.4, 0.5,
                                                         0.6, 0.7, 0.8, 0.9, 1])
        ### colsample_bytree = 0.5
        best_score, best_reg_alpha, \
            tuning_reg_alpha = tuningHyperreg_alpha(X, y, best_n_estimators, best_lr, 
                                                    best_maxdepth, best_child,
                                                    best_gamma, best_Subsample,
                                                    best_colsample_bytree,
                                                    [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                     0.6, 0.7, 0.8, 0.9, 1])
        ### reg_alpha = 0.5
        best_score, best_reg_lambda, \
            tuning_reg_lambda = tuningHyperreg_lambda(X, y, best_n_estimators, best_lr, 
                                                      best_maxdepth, best_child,
                                                      best_gamma, best_Subsample, 
                                                      best_colsample_bytree, best_reg_alpha,
                                                      [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                       0.6, 0.7, 0.8, 0.9, 1])
        ### reg_lambda = 1
        tuning_records = [tuning_n_estimator, tuning_lr, tuning_maxdepth, 
                          tuning_child, tuning_gamma, tuning_Subsample,
                          tuning_bytree, tuning_reg_alpha, tuning_reg_lambda]
        dump(tuning_records, REPO_RESULT_LOCATION + '03_tuninglist_noah_withoutAP.joblib')
        
        model = testBestModel(X, y, tree_method='gpu_hist', 
                              n_estimators = best_n_estimators, learning_rate = best_lr,
                              max_depth = best_maxdepth, min_child_weight = best_child, 
                              gamma = best_gamma, subsample = best_Subsample, 
                              colsample_bytree = best_colsample_bytree, reg_alpha = best_reg_alpha,
                              reg_lambda = best_reg_lambda)
        
        shap_value = getShap(model, X)
        
        dump(shap_value, REPO_RESULT_LOCATION + '03_TreeShapStdize_noah_withoutAP.joblib') 
        shap_value = pd.DataFrame(shap_value)
        
        dataset_to_analysis = makeDatasetWithShap(df, shap_value)
        dataset_to_analysis.to_csv(REPO_RESULT_LOCATION + '03_mergedXSHAPStdize_noah_withoutAP.csv')
        
        importance = model.get_booster().get_score(importance_type='weight')
        print(importance)
        dump(importance, REPO_RESULT_LOCATION + '03_importance_noah_withoutAP.joblib')
        
        
    diff = False
    if diff:
        df, X, y = getXandYdiff()
        best_score, best_n_estimators, \
            tuning_n_estimator = tuningHyperNestimator(X, y, 
                                                        [100, 200, 300, 400, 500,
                                                         600, 700, 800, 900, 1000,
                                                         1100, 1200, 1300, 1400,
                                                         1500, 1600, 1700, 1800,
                                                         1900, 2000, 2100, 2200, 
                                                         2300, 2400, 2500, 2600,
                                                         2700, 2800, 2900, 3000])
        ### n_estimators = 3000
        best_score, best_lr, \
            tuning_lr = tuningHyperLr(X, y, best_n_estimators, 
                                      [0.01, 0.05, 0.1, 
                                       0.2, 0.3, 0.4, 
                                       0.5, 0.6, 0.7, 0.8])
        
        ### learning_rate = 0.3
        best_score, best_maxdepth, \
            tuning_maxdepth = tuningHyperMaxDepth(X, y, best_n_estimators, best_lr,
                                                  [3, 4, 5, 6, 7, 8, 9, 10,
                                                   11, 12, 13, 14, 15, 16, 17,
                                                   18, 19, 20, 21, 22, 23, 24,
                                                   25])
        ### max_depth = 18
        best_score, best_child, \
            tuning_child = tuningHyperChild(X, y, best_n_estimators, best_lr, 
                                            best_maxdepth, 
                                            [1, 2, 3, 4, 5, 
                                             6, 7, 8, 9, 10])
        ### min_child_weight=2
        best_score, best_gamma, \
            tuning_gamma = tuningHyperGamma(X, y, best_n_estimators, best_lr,
                                            best_maxdepth, best_child,
                                            [0, 1, 2, 3, 4, 5])
        ### gamma = 0
        best_score, best_Subsample, \
            tuning_Subsample = tuningHyperSubsample(X, y, best_n_estimators, best_lr,
                                                    best_maxdepth, best_child,
                                                    best_gamma, 
                                                    [0.5, 0.6, 0.7, 0.8, 0.9, 1])
        ### subsample = 1
        best_score, best_colsample_bytree, \
            tuning_bytree = tuningHypercolsample_bytree(X, y, best_n_estimators, best_lr,
                                                        best_maxdepth, best_child,
                                                        best_gamma, best_Subsample,
                                                        [0.1, 0.2, 0.3, 0.4, 0.5,
                                                         0.6, 0.7, 0.8, 0.9, 1])
        ### colsample_bytree = 0.5
        best_score, best_reg_alpha, \
            tuning_reg_alpha = tuningHyperreg_alpha(X, y, best_n_estimators, best_lr, 
                                                    best_maxdepth, best_child,
                                                    best_gamma, best_Subsample,
                                                    best_colsample_bytree,
                                                    [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                     0.6, 0.7, 0.8, 0.9, 1])
        ### reg_alpha = 0.5
        best_score, best_reg_lambda, \
            tuning_reg_lambda = tuningHyperreg_lambda(X, y, best_n_estimators, best_lr, 
                                                      best_maxdepth, best_child,
                                                      best_gamma, best_Subsample, 
                                                      best_colsample_bytree, best_reg_alpha,
                                                      [0, 0.1, 0.2, 0.3, 0.4, 0.5,
                                                       0.6, 0.7, 0.8, 0.9, 1])
        ### reg_lambda = 1
        tuning_records = [tuning_n_estimator, tuning_lr, tuning_maxdepth, 
                          tuning_child, tuning_gamma, tuning_Subsample,
                          tuning_bytree, tuning_reg_alpha, tuning_reg_lambda]
        dump(tuning_records, REPO_RESULT_LOCATION + '05_tuninglist_firstdif_noah_withoutAP.joblib')
        
        model = testBestModel(X, y, tree_method='gpu_hist', 
                              n_estimators = best_n_estimators, learning_rate = best_lr,
                              max_depth = best_maxdepth, min_child_weight = best_child, 
                              gamma = best_gamma, subsample = best_Subsample, 
                              colsample_bytree = best_colsample_bytree, reg_alpha = best_reg_alpha,
                              reg_lambda = best_reg_lambda)
        
        shap_value = getShap(model, X)
        
        dump(shap_value, REPO_RESULT_LOCATION + '05_TreeShapStdize_firstdif_noah_withoutAP.joblib') 
        shap_value = pd.DataFrame(shap_value)
        
        dataset_to_analysis = makeDatasetWithShap(df, shap_value)
        dataset_to_analysis.to_csv(REPO_RESULT_LOCATION + '05_mergedXSHAPStdize_firstdif_noah_withoutAP.csv')
        





"""
print(best_n_estimators, best_lr, best_maxdepth, best_child, best_gamma, best_Subsample, best_colsample_bytree, best_reg_alpha, best_reg_lambda)
3000, 0.3, 17, 2, 0, 1, 0.8, 0.2, 0.5
87.95% 99.81%
### .csv

"""






