# -*- coding: utf-8 -*-
"""
Spider Download Data from https://eogdata.mines.edu/nighttime_light/monthly/v10/2021/202106/vcmcfg/

Data: Monthly Nighttime Light 

Created on Wed Feb  2 15:48:42 2022

@author: M.L.
"""

from selenium.webdriver.support.ui import Select
import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd
import tarfile
import glob
import os

driver = webdriver.Chrome(ChromeDriverManager(version="107.0.5304.62").install())

month = ['01', '02', '03', '04', '05', '06',
         '07', '08', '09', '10', '11', '12']
year = 2019
i = 0
while i < 12:
    locationService = 'https://eogdata.mines.edu/nighttime_light/monthly/v10/' + str(year) + '/' + str(year) + month[i] + '/vcmslcfg/'
    print(locationService)

    driver.get(locationService)
    driver.find_element_by_xpath(r'//*[@id="indexlist"]/tbody/tr[5]/td[2]/a').click()
    time.sleep(90)
    i = i + 1
    
year = 2020
i = 0
while i < 12:
    locationService = 'https://eogdata.mines.edu/nighttime_light/monthly/v10/' + str(year) + '/' + str(year) + month[i] + '/vcmslcfg/'
    print(locationService)

    driver.get(locationService)
    driver.find_element_by_xpath(r'//*[@id="indexlist"]/tbody/tr[5]/td[2]/a').click()
    time.sleep(90)
    i = i + 1

def extract(tar_url, extract_path='.'):
    print(tar_url)
    tar = tarfile.open(tar_url, 'r')
    for item in tar:
        tar.extract(item, extract_path)
        tar.close()
        break
    
tgzFileList = glob.glob("D:/11_Article/01_Data/05_NTL/NTL_Raster/temp2/*.tgz")

for tar_location in tgzFileList:
    extract_path = "D:/11_Article/01_Data/05_NTL/NTL_Raster/temp2"
    extract(tar_location, extract_path)    
    
for tar_location in tgzFileList:
    os.remove(tar_location)