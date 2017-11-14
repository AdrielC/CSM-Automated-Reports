# Clear out your Environment
rm(list = ls())

# Set your working directory to your central folder that contains all of the data you need
setwd("~/MAIN/BCC/RESTReporting/")

# Set this for easily installing and loading packages. This is very useful when sharing code
if(!("easypackages" %in% installed.packages()[,"Package"])) install_packages("easypackages"); library(easypackages)

# Create a list of your packages as strings and then install/load as needed
list.of.packages <- c("tidyr", "dplyr", "RecordLinkage")
packages(list.of.packages, prompt = F)

# Create the master club report of each club by combining all the csv files into one dataframe and adding the club column

file_list <- list.files("./rosters/")

## Only run this once. This creates the combined list of everyone in each club.
for (file in file_list){
  
  ## if the merged master.club doesn't exist, create it
  if (!exists("master.club")){
    master.club <- read.csv(paste0("./rosters/",file), header=TRUE, sep=",")
    master.club$club <- sprintf("%s", unlist(strsplit(file, ".", fixed = T)))[1]
  }
  
  ## if the merged master.club does exist, append to it
  if (exists("master.club")){
    temp_master.club <-read.csv(paste0("./rosters/",file), header=TRUE, sep=",")
    temp_master.club$club <- sprintf("%s", unlist(strsplit(file, ".", fixed = T)))[1]
    master.club<-rbind(master.club, temp_master.club)
    rm(temp_master.club)
  }
}

# Drop all of the unused factor levels in the club variable after making it a factor
master.club$club <- droplevels(as.factor(master.club$club))

# Read in the full club attendee data from 2017-2018
Attendees <- read.csv("./BridgeREST/2017-2018 Club Event Attendees.csv")

# Clean the data - drop all NAs and unused levels
Attendees %>% subset(!(is.na(student..Student.ID))) %>% droplevels() -> Attendees
## Rename the column names to make it easy to work with
colnames(Attendees) <- c("StudentName", "EventDate", "club", "ClubEventName", "StudentID", "Email")
## Rename the club factor levels to match the club factor levels in master.club
levels(Attendees$club) <- c("AIS", "ALPFA", "BCCBrand", "BAP", "Acc Soc", "BYUFS", "MA", "BYUMarkets", "BSC", "CFC", "ExDM",
                            "GSCA", "IMA", "IBC", "MCC", "NMSA", "PreMa", "PBC", "PEVC", "SHRM", "TRC", "MUWIB", "WSOA")

# Create the non-member event Attendee List for each club
## First Create an empty list
clubReports <- list()
## Second, append each report to that list by club name
for(Club in levels(master.club$club)){
  tmpMaster <- subset(master.club, master.club$club == Club)
  tmpAttend <- subset(Attendees, Attendees$club == Club)
  assign(Club, subset(tmpAttend, !(tmpAttend$Email %in% tmpMaster$Email))) %>% 
    select(-StudentID) -> clubReports[[Club]]
}
## Third, save each report in the list as a new csv in whatever working directory you select
setwd("../Club data/PDF 11-14-17/NonMember List/")
lapply(1:length(clubReports), function(i) write.csv(clubReports[[i]], 
                                                    file = paste0(names(clubReports[i]), ".csv"),
                                                    row.names = FALSE))




