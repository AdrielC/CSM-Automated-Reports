# CSM-Automated-Reports

### Written in Anaconda distribution Python 3.3+, and R
### This is used to automate reports for the following or more purposes:
1) Creating reports of students who attend a club but are not a part of it
2) Tracking club event attendance
3) Measuring student engagement on the CSM platform
etc.

## Important files
### 1) setup.py
This is where you will need to input your API token in order to authenticate and authorize your REST API access to CSM. You can also create a MongoDB database to temporarily store large amounts of data to the disk.

### 2) reports.py
This script is where the two main report functions are defined: #1 GetReportList() and #2 RunReport(). The first allows you to query all the labels (names) of the existing reports in CSM. Given a keyword, the function will return a dictionary object of report labels and their corresponding keys. The second function runs the given report (by reportName and reportId), and then checks the status of the report. Once the report is completed, the function pulls the data of the given report and saves it as a .csv with a name corresponding to the report label in CSM

### 3) MainRun.py
This script is where all the functions are executed. This is an example of constructing multi-report runs and downloads. You would be able to alter the RunReport function to return Pandas data frame objects instead, which would allow for more complex data joining and report merging as needed.

### 4) RClubAttendance.R
This is an example of further cleaning the data exported from the REST reports. It is possible to call R scripts inside of Python as a subprocess if a cross-language data team deemed it necessary. As I am more comfortable in R for data cleaning and transformation, I have included this script here for the sake of example of a finished report.

<!--
###############################################
########## Symplicity CSM REST API ############
###############################################
##                           M               ##
##                          MMM              ##
##                        MMMMMMM            ##
##                      IMMMMMMMMM           ##
##                     MMMM MMM MMMM         ##
##                   MMMMM  MMM  MMMM:       ##
##                  MMMM:   MMM   IMMMM      ##
##                MMMMM     MMM     MMMMM    ##
##              MMMMMMMMMMMMMMM      MMMMM   ##
##             MMMMMMMMMMMMMMMM       MMMMM  ##
##           MMMMM          MMM      MMMM    ##
##          MMMMM           MMM    MMMMM     ##
##        MMMMM             MMM  IMMMM       ##
##      MMMMM               MMM MMMMN        ##
##     MMMMM                MMMMMMMM         ##
##   MMMMM                  MMMMMM           ##
##  MMNM                    MMMM             ##
###############################################
######### Symplicity CSM REST API #############
############################################### -->
