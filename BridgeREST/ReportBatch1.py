###########################################
######### Symplicity CSM REST API #########
###########################################

import setup
from reports import *
from pymongo import MongoClient
import json

mongo_client = MongoClient(setup.MONGO_ADDRESS, setup.MONGO_PORT)
reportsDB = mongo_client.BYUbridge.reports

def studentNameMerge():
    print("Lmao")

def main():
    dataframeOut = []
    reportList = {}
    # To run reports individually, you only need to supply the RunReport function with
    # the report ID from the Bridge(CSM). Use the function GetReportList to see the report IDs.
    # The reports need to be fed into the RunReport as dictionary
    reportList["2015-2018 Club Event Attendees"] = "2aeeeb2dd7bab015a88858cfb65fb802"
    # reportList["Full Student List **ADRIEL**"] = "e5dcb7ef720881dc8a580753d14d9e84"
    reportList["Company info sessions **ADRIEL**"] = "b137771b4028f6b311e5dc0ee4ad13cf"
    reportList["OCR Job Application Count **ADRIEL**"] = "bedde81ee42953863032c71bc630207c"
    for reportName, reportId in reportList.items():
        dataframeOut.append(RunReport(reportName, reportId, dataframe = True, csv = False))




if __name__ == "__main__":
    main()
