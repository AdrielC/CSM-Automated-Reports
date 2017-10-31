###########################################
######### Symplicity CSM REST API #########
###########################################

import setup
from reports import *

def main():
    reportList = {"2015-2018 Club Event Attendees":"2aeeeb2dd7bab015a88858cfb65fb802"}
    for reportName, reportList in reportList.items():
        RunReport(reportName, reportName)
