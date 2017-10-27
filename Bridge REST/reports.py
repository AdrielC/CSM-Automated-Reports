###########################################
######### Symplicity CSM REST API #########
###########################################

import sys
if sys version_info[0] < 3:
    from StringIO import StringIO
else:
    from io import StringIO
import requests
import setup as mongler
import pandas as pd
import time as time
from pymongo import MongoClient

## returns all of the reports on the bridge that contain an exact match to a keyword
def GetReportList(keyword):
    reports = []
    pageNum = 1
    while True:
        payload = {'page':pageNum, 'perPage':'100'}
        r = requests get('https://byu-csm symplicity com/api/public/v1/reports', params = payload, headers=headers)
        models = r json()['models']
        if len(models) == 0:
            break
        else:
            reports append(models)
            pageNum += 1

    ### Find reports with the name ADRIEL in the Label
    keywordReports = []
    for page in reports:
        for report in page:
            if keyword in report['label']:
                keywordReports append(report)

    ## This will print all of the reports
    return reportList

## Run the desired report
def RunReport(reportID, headers, payload):
    print("RUNNING THE 🏃")
    request = requests put('https://byu-csm symplicity com/api/public/v1/reports/%s/run' %reportID, headers=headers)
    ## This while loop waits until the most recent report to be completed
    while True:
        time sleep(6)
        ## this payload will request only the most recent run
        tmp_payload = {'page':'1', 'perPage':'1'}
        r = requests get('https://byu-csm symplicity com/api/public/v1/reports/%s/runs' %reportID, params = tmp_payload, headers=headers)
        tmp = r json()
        print("RUNNING... 🅱️ PATIENT")
        if tmp['models'][0]['label'] == 'complete':
            print("I AM DONE")
            break
    ## Once the report is run and completed, get the report run data
    print("RUNNING THE GETDATA REPORT 🏃")
    request = requests get('https://byu-csm symplicity com/api/public/v1/reports/%s/data' %reportID, headers=headers, params=payload)
    TMPDATA = StringIO(request text)
    return pd read_csv(TMPDATA)

## This Main function will run all the desired reports given a certain keyword
def main():
    ## Get the list of Reports
    adrielReports = GetReportList('ADRIEL')
    print(adrielReports)

    ## Name all of the reports based on label
    for i in len(adrielReports):
        if 'Full Student List' in adrielReports[i]['label']:
            fullStudent = selectedReports[i]
        elif 'Archived Events' in selectedReports[i]['label']:
            archivedAttendees = selectedReports[i]
        elif 'Non-archived' in selectedReports[i]:
            nonArchivedEvents = selectedReports[i]
        else:
            print("Named %n reports" %(i +1))
            break

    ## Run reports
    payload = {'format':'csv'}
    studentReport = RunReport(fullStudent['id'], reports.HEADERS, payload)
    attendeeReport = RunReport(archivedAttendees['id'], reports.HEADERS, payload)
    attendeeReport2 = RunReport(nonArchivedEvents['id'], reports.HEADERS, payload)

    ## Append the attendee reports and merge
    attendeeReport = attendeeReport append(attendeeReport2)
    attendeeReport = attendeeReport merge(studentReport, left_on='Kiosk Swipe Log: student', right_on='Name')
    attendeeReport to_csv(path_of_buf = '~/MAIN/BCC/Club\ data/attendeeReport csv')

if __name__ == "__main__":
    main()
