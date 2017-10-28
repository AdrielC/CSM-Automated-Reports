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
    print("\n\nPlease provide a keyword to search the names of each CSM report. IGNORECASE")
    # keyword = 'exact report label(name)' # Uncomment this and input the exact report name if you want one report
    keyword = input('\n\tSearch: ')
    reports = []
    pageNum = 1
    tmp = True
    while True:
        payload = {'page':pageNum, 'perPage':'100'}
        try:
            r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports', params = payload, headers=setup.HEADERS)
            models = r.json()['models']
            if len(models) == 0:
                break
            else:
                reports.append(models)
                pageNum += 1
        except:
            print("Error: A report was cancelled while it was running")

    ### Find reports with the keyword in the Label
    reportList = {}
    try:
        for page in reports:
            for report in page:
                if re.search(keyword, report['label'], re.IGNORECASE): # This searches all the report labels for your keyword, ignoring case
                    label = report['label']
                    reportList[label] = report['id']
    except:
        print("\n🚫  Invalid search, must contain normal characters. Please try again")
        return GetReportList()

    print("\n 🔎  Bridge Report Search Result 🔍‍ \n")
    for reportName, reportId in reportList.items():
        print("Report name: %s \t Report Id: %s" %(reportName, reportId))

    # val = "n" # Uncomment this if you want to run all the reports from a query
    val = input("\nWould you like to search again? y/n --> ")
    if val == "n":
        return reportList
    elif val == "y":
        return GetReportList()
    else:
        while True:
            if val not in ("y", "n"):
                val = input("Invalid response. Would you like to search again? y/n --> ")
                continue
            elif val == "y":
                return GetReportList()
            elif val == "n":
                return reportList
                break

## Run the desired report. Accepts a key:value pair as the report arguments. Optional arguments: directory -- you can specify the directory of where to save the csv, dataframe -- if True, the function will return a dataframe object of the report, csv -- if false, no csv will be written
def RunReport(reportName, reportId, headers=setup.HEADERS, directory = os.getcwd(), dataframe = False, csv = True):
    print("\nRUNNING THE REPORT: %s 🏃" %reportName)
    request = requests.put('https://byu-csm.symplicity.com/api/public/v1/reports/%s/run' %reportId, headers=headers)
    ## This while loop waits until the most recent report to be completed
    while True:
        time.sleep(6)
        ## this payload will request only the most recent run
        tmp_payload = {'page':'1', 'perPage':'1'}
        r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/runs' %reportId, params = tmp_payload, headers=headers)
        tmp = r.json()
        print("RUNNING... 🅱️  patient")
        if tmp['models'][0]['label'] == 'complete':
            print("\nReport has finished  ✅\n")
            break
        ## Once the report is run and completed, get the report run data

    print("RUNNING THE GET:DATA REPORT 🏃")
    request = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/data' %reportId, headers=headers, params=setup.dPAYLOAD)
    TMPDATA = StringIO(request.text)
    finishedReport = pd.read_csv(TMPDATA)
    if csv == True:
        finishedReport.to_csv(directory + "/" + reportName + ".csv", index = False)
        print('\nSaved file to ' + directory)
    if dataframe == True:
        return finishedReport
