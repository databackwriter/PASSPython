# -*- coding: utf-8 -*-
"""
Created on Tue Oct 16 16:06:39 2018

@author: factgasm
"""

import pandas as pd
import numpy as np
from bs4 import BeautifulSoup
import requests

url="https://www.theguardian.com/football/premierleague/table"
response = requests.get(url)
html = response.text
soup = BeautifulSoup(html, "html.parser")

localclass="table table--football table--league-table table--responsive-font table--striped"
tablestats = soup.find("table", attrs={"class":localclass})

df = pd.DataFrame(np.nan, index=range(0,20), columns = ["P","Team","GP","W","D","L","F","A","GD","Pts","Form"],dtype=np.str)
rows = tablestats.find_all("tr")
row_marker = 0
for row in rows:
    column_marker = 0
    columns = row.find_all("td")
    if (len(columns)) >0: # ie not the header row
        for column in columns:
            columnentrant = column.get_text().replace("\n", "")
            df.iat[row_marker,column_marker] = columnentrant
            column_marker += 1
        row_marker +=1
print(df)






