###########################################
######### Symplicity CSM REST API #########
###########################################

### This is where the magic happens. Call the report functions and
###### perform any transformations on the data in this script

import setup
from reports import *
import argparse
from pymongo import MongoClient

## Configure mongo if you need to use it
mongo_client = MongoClient(setup.MONGO_ADDRESS, setup.MONGO_PORT)
reportsDB = mongo_client.BYUbridge.reports


### This Main function will run all the desired reports given a certain keyword

def main():
    ## Get the list of Reports
    reportList = GetReportList()

    for reportName, reportId in reportList.items():
        RunReport(reportName, reportId)

    print("I AM DONE WITH ALL YOUR REPORTS! 🆒")

if __name__ == "__main__":
    main()
