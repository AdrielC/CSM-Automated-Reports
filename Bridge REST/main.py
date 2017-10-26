### Conda env for this is REST. Use $ source activate REST
import sys
if sys.version_info[0] < 3:
    from StringIO import StringIO
else:
    from io import StringIO
import requests
import setup as mongler
import pandas as pd
import time as time
from pymongo import MongoClient

## Configure mongo
mongo_client = MongoClient(mongler.MONGO_ADDRESS,mongler.MONGO_PORT)
reportsDB = mongo_client.BYUbridge.reports

## Make requests to bridge for list of reports
headers = {"Authorization":"Token %s" % mongler.TOKEN}

## returns all of the reports on the bridge that contain an exact match to a keyword
def GetReportList(keyword):
    reports = []
    pageNum = 1
    while True:
        payload = {'page':pageNum, 'perPage':'100'}
        r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports', params = payload, headers=headers)
        models = r.json()['models']
        if len(models) == 0:
            break
        else:
            reports.append(models)
            pageNum += 1

    ### Find reports with the name ADRIEL in the Label
    keywordReports = []
    for page in reports:
        for report in page:
            if keyword in report['label']:
                keywordReports.append(report)

    ## This will print all of the reports
    return keywordReports

## Run the desired report
def RunReport(reportID, headers, payload):
    request = requests.put('https://byu-csm.symplicity.com/api/public/v1/reports/%s/run' %reportID, headers=headers)
    ## This while loop waits until the most recent report to be completed
    while True:
        time.sleep(6)
        ## this payload will request only the most recent run
        tmp_payload = {'page':'1', 'perPage':'1'}
        r = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/runs' %reportID, params = tmp_payload, headers=headers)
        tmp = r.json()
        print("RUNNING... 🏃🏃🏃🏃🏃🏃🏃🏃 🅱️ PATIENT")
        if tmp['models'][0]['label'] == 'complete':
            print("I AM DONE")
            break
    ## Once the report is run and completed, get the report run data
    print("LMAO. 🅱️  CHILL. I AM NOW RUNNING THE GETDATA REPORT 🏃🏃🏃🏃🏃🏃🏃🏃")
    request = requests.get('https://byu-csm.symplicity.com/api/public/v1/reports/%s/data' %reportID, headers=headers, params=payload)
    TMPDATA = StringIO(request.text)
    return pd.read_csv(TMPDATA)

## This Main function will run all the desired reports given a certain keyword
def main():
    ## Get the list of Reports
    adrielReports = GetReportList('ADRIEL')
    print(adrielReports)

    ## Name all of the reports based on label
    for i, report in enumerate(adrielReports):
        if 'Full Student List' in report['label']:
            fullStudent = report
        elif 'Archived Events' in report['label']:
            archivedAttendees = report
        elif 'Non-archived' in report['label']:
            nonArchivedEvents = report
        else:
            print("Named %n reports" %(i +1))
            break

    print("I WILL NOW RUN THE REPORTS HAHAHAHAHA. The first one is the studentReport 🏃🏃🏃🏃🏃🏃🏃🏃")
    ## Run reports
    payload = {'format':'csv'}
    studentReport = RunReport(fullStudent['id'], headers, payload)
    print("I WILL NOW RUN THE FIRST attendeeReport 🏃🏃🏃🏃🏃🏃🏃🏃")
    attendeeReport = RunReport(archivedAttendees['id'], headers, payload)
    print("I WILL NOW RUN ANOTHER attendeeRepor 🏃🏃🏃🏃🏃🏃🏃🏃")
    attendeeReport2 = RunReport(nonArchivedEvents['id'], headers, payload)
    print("I WILL NOW CLEAN THE DATA AND EXPORT")
    ## Append the attendee reports and merge
    attendeeReport3 = attendeeReport.append(attendeeReport2)
    attendeeReport3.columns = ['Event title', 'Club', 'Date', 'Name']
    attendeeReport4 = pd.merge(attendeeReport3, studentReport, how="left", on="Name")
    attendeeReport4.to_csv('~/MAIN/BCC/Club data/attendeeReport.csv', index = False)
    studentReport.to_csv('~/MAIN/BCC/Club data/studentReport.csv', index = False)

    print("I AM DONE WITH ALL YOUR REPORTS!!!! ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️")
if __name__ == "__main__":
    main()
