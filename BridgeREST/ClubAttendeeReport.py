###########################################
######### Symplicity CSM REST API #########
###########################################

import setup
from reports import *
from pymongo import MongoClient
import json

mongo_client = MongoClient(setup.MONGO_ADDRESS, setup.MONGO_PORT)
reportsDB = mongo_client.BYUbridge.reports
directoryOUT = "~/MAIN/BCC/Club data/Full Data/"

def studentNameMerge():
    print("Lmao")

def main():
    dataframeOut = []
    reportList = {}
    # To run reports individually, you only need to supply the RunReport function with
    # the report ID from the Bridge(CSM). Use the function GetReportList to see the report IDs.
    # The reports need to be fed into the RunReport as dictionary
    reportList["2013-2018 Club Event Attendees **ADRIEL**"] = "79d7e7e4a0f91c0cb17127f95429fd46"
    reportList["2017-2018 Club Event Attendees"] = "c5237823fed6ede58f19b3e105289803"
    reportList["Full Student List **ADRIEL**"] = "e5dcb7ef720881dc8a580753d14d9e84"
    for reportName, reportId in reportList.items():
        dataframeOut.append(RunReport(reportName, reportId, dataframe = False, csv = True, directory = directoryOUT))




if __name__ == "__main__":
    main()
