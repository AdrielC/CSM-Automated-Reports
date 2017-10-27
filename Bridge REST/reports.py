###########################################
######### Symplicity CSM REST API #########
###########################################

import sys
if sys.version_info[0] < 3:
    from StringIO import StringIO
else:
    from io import StringIO
import requests
import setup
import pandas as pd
import time as time
from pymongo import MongoClient
import re
import os

### This function returns a list of JSON objects, each being an existing report on CSM that has
###### has a label that contains the input keyword argument.

def GetReportList():
    while True:
        print("Please provide a keyword to search the names of each CSM report. IGNORECASE")
        keyword = input('Search: ')
        reports = []
        pageNum = 1
        tmp = True
        while True:
            payload = {'page':pageNum, 'perPage':'100'}
            r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports', params = payload, headers=setup.HEADERS)
            models = r.json()['models']
            if len(models) == 0:
                break
            else:
                reports.append(models)
                pageNum += 1

        ### Find reports with the keyword in the Label
        reportList = {}
        for page in reports:
            for report in page:
                if re.search(keyword, report['label'], re.IGNORECASE): # This searches all the report labels for your keyword, ignoring case
                    label = report['label']
                    reportList[label.replace(" ", "")] = report['id']

        print(reportList)
        val = input("Would you like to search again? y/n --> ")
        if val == "n":
            break
        while True:
            if val is not ("y" or "n"):
                val = input("Invalid response. Would you like to search again? y/n --> ")
            else:
                break
        if tmp == False:
            break
    return reportList

## Run the desired report. Accepts a key:value pair as the report argument

def RunReport(reportName, reportId, headers=setup.HEADERS, directory = os.chdir(path)):
    print("RUNNING THE REPORT: %s 🏃" %reportName)
    request = requests.put('https://byu-csm.symplicity.com/api/public/v1/reports/%s/run' %reportId, headers=headers)
    ## This while loop waits until the most recent report to be completed
    while True:
        time.sleep(12)
        ## this payload will request only the most recent run
        tmp_payload = {'page':'1', 'perPage':'1'}
        r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/runs' %reportId, params = tmp_payload, headers=headers)
        tmp = r.json()
        print("RUNNING... 🅱️ patient")
        if tmp['models'][0]['label'] == 'complete':
            print("I AM DONE")
            break
    ## Once the report is run and completed, get the report run data
    print("RUNNING THE GET:DATA REPORT 🏃")
    request = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/data' %reportId, headers=headers, params=setup.dPAYLOAD)
    TMPDATA = StringIO(request.text)
    finishedReport = pd.read_csv(TMPDATA)
    finishedReport.to_csv(directory + reportName + '.csv', index = False)
