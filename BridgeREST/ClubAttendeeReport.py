###########################################
######### Symplicity CSM REST API #########
###########################################

import setup
from reports import *
from pymongo import MongoClient

mongo_client = MongoClient(setup.MONGO_ADDRESS, setup.MONGO_PORT)
reportsDB = mongo_client.BYUbridge.reports

def studentNameMerge():
    print("Lmao")

def main():
    dataframeOut = []
    reportList = {}
    reportList["2015-2018 Club Event Attendees"] = "2aeeeb2dd7bab015a88858cfb65fb802"
    reportList["2017-2018 Full Student List"] = "e5dcb7ef720881dc8a580753d14d9e84"
    for reportName, reportId in reportList.items():
        dataframeOut.append(RunReport(reportName, reportId, dataframe = True, csv = False))

    print(dataframeOut)


if __name__ == "__main__":
    main()
