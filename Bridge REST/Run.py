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

## This Main function will run all the desired reports given a certain keyword
def main():
    ## Get the list of Reports
    eventReport = GetReportList('ADRIEL')
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

    print("I WILL NOW RUN THE REPORTS HAHAHAHA. The first one is the studentReport 🏃🏃🏃🏃🏃🏃🏃🏃")
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

    print("I AM DONE WITH ALL YOUR REPORTS!!!! ❤️")
if __name__ == "__main__":
    main()
