### This script allows you to interact with Google Analytics data and stream it into R
rm(list = ls())
### This checks to see if easypackages is installed. If not, it will install it, then load it
if(!("easypackages" %in% installed.packages()[,"Package"])) install_packages("easypackages"); library(easypackages)
### List all the packages you you need and then use the packages function to install and load all the packages in the list
list.of.packages <- c("ggplot2", "dplyr", "fcuk", "RGoogleAnalytics", "ggfortify", "forecast", "fpp2")
packages(list.of.packages, prompt = F)

setwd("~/MAIN/BCC/RESTReporting/RShiny Dashboards/") ### Set this to whatever directory you want

# Step One: Authorize

### Get your cliend ID and secret at https://console.developers.google.com/apis/dashboard

source("GAsetup.R") # either source your athentication from another file if you want to keep your clientID and clientSecret secure, or follow the instructions below

# Step Three: Construct your queries

### We need to create a list of Club content authors to filter pages that belong to each club
ClubAuthors <- list(BAS = "Accounting Society", 
                    ALPFA = "ALPFA", 
                    AIS = "Association for Information Systems",
                    BAP = "Beta Alpha Psi", 
                    BSC = "Business Strategy Club", 
                    CFC = c("Corporate Finance Club","Tina Ashby"),
                    ExDMC = c("Experience Design and Management Club (ExDMC)","RecManagement Assistant","Virginia Rosenthal"), 
                    BYUFS = c("Finance Society","Private Banking Group"),
                    GSCA = "Global Supply Chain Association", 
                    IMA = "Institute of Management Accountants",
                    IBC = "Investment Banking Club", 
                    MCC = "Management Consulting Club", 
                    MA = c("Marketing Assistant","Marketing Association","Mike Neuffer"), 
                    BYUMC = "Markets Club",
                    NMSA = "Non-Profit Management Student Association", 
                    PreMA = "Pre-Management Student Association (PreMa)",
                    PBC = "Private Banking Club", 
                    PEVC = "Private Equity and Venture Capital Club", 
                    REC = "Real Estate Club",
                    SHRM = "Society for Human Resource Management", 
                    TRC = "Therapeutic Recreation Club",
                    WIB = "Women In Business Club",
                    WSOA = "Women of the School of Accountancy"
)
  

### Test out different queries with a GUI: https://ga-dev-tools.appspot.com/query-explorer/
### Proper Google names of dimensions and metrics: https://developers.google.com/analytics/devguides/reporting/core/dimsmets # Referece this when building your queries

Q.MA2017 <- Init(start.date = "2017-09-02", # GA will return data for the day before this date
                    end.date = as.Date(Sys.time()), # This returns the current date
                    dimensions = "ga:date, ga:Author", # This is your date column
                    metrics = "ga:users, ga:sessions, ga:avgTimeOnPage, ga:avgSessionDuration", # These are the site measurements you want to examine
                    filters = paste("ga:Author == ", 
                    max.results = 10000,
                    table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website
