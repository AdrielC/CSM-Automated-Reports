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
colnames(Attendees) <- c("StudentName", "EventDate", "club", "ClubEventName", "Student.ID", "Email")

# Left Join the Full Student List to get data on Major
FullStudent <- read.csv("./../Club data/Full Data/Full Student List **ADRIEL**.csv") %>% select(Email, Major)

EconJoinAttendee <- suppressWarnings(left_join(Attendees, FullStudent, by="Email")) %>% .[which(.$Major=="Economics (No Emphasis)"),]
EconJoinMember <- suppressWarnings(left_join(master.club, FullStudent, by="Email")) %>% .[which(.$Major=="Economics (No Emphasis)"),]

Reports <- list(EconJoinAttendee, EconJoinMember)

# deparse(substitute()) returns the name of a variable. Export the files here

lapply(1:length(Reports), function(i) write.csv(Reports[i], file = paste0("EconStudentReport", i, ".csv"), row.names = FALSE))
