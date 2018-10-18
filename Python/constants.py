#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 30 05:44:45 2018

@author: petermoore

file to include constants and functions that typically are called once and only once (for example those that read from yaml)
"""

#path file function
def setPathFile():
    from sys import platform
    if platform == "darwin":
        r = "/Users/petermoore/Documents/GitHub/PASSPython/Python"
    elif platform == "win32":
        r = "trevor"
    return r


# constants

PATH_FILE = setPathFile()

# session set up
import os
os.chdir(PATH_FILE)
import sys
sys.path.append(PATH_FILE) #add local directory to path

# constants
PATH_CONNYAML = "connections.yaml"
def getDSNfromYAML(yamlfile):
    import yaml
    with open(yamlfile, 'r') as f:
        doc = yaml.load(f)
        pdsn = doc["pyssmssqlconn"]["DSN"]
        puser = doc["pyssmssqlconn"]["user"]
        ppassword = doc["pyssmssqlconn"]["password"]
    dsn="DSN="+pdsn+";UID="+puser+";PWD="+ppassword
    alchemydsn = "mssql+pyodbc://"+puser+":"+ppassword+"@"+pdsn
    return dsn, alchemydsn, pdsn, puser, ppassword
# database set up
DSN, ALCHEMYDSN, pdsn, puser, ppassword = getDSNfromYAML(yamlfile=PATH_CONNYAML)
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()
engine = create_engine(ALCHEMYDSN)
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine.execution_options(isolation_level='READ COMMITTED'))
session = DBSession()

print(DSN)





