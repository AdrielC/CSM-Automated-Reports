library(dplyr)
library(tidyr)
library(RecordLinkage)

rm(list = ls())

setwd("~/MAIN/BCC/Club data/rosters/")

file_list <- list.files()

### Only run this once. This creates the combined list of everyone in each club.
for (file in file_list){
  
  # if the merged master.club doesn't exist, create it
  if (!exists("master.club")){
    master.club <- read.csv(file, header=TRUE, sep=",")
    master.club$club <- sprintf("%s", unlist(strsplit(file, ".", fixed = T)))[1]
  }
  
  # if the merged master.club does exist, append to it
  if (exists("master.club")){
    temp_master.club <-read.csv(file, header=TRUE, sep=",")
    temp_master.club$club <- sprintf("%s", unlist(strsplit(file, ".", fixed = T)))[1]
    master.club<-rbind(master.club, temp_master.club)
    rm(temp_master.club)
  }
}

### This creates the list of club event attendees and cleans it
setwd("~/MAIN/BCC/Club data")
attendees <- read.csv('attendeeReport.csv', header = T)

### Identify the records (rows) in the attendee list that are not present in the Master club list
non.members <- subset(attendees, !(attendees$Email %in% master.club$Email)) %>%
  filter(Email != "NA" & Name != "") %>%
  filter(Email != "") %>%
  .[,c("Event.title", "Club", "Date", "Name", "Email")]



### Write out the non-member list to a csv!
write.csv(non.members, "non-member event attendees.csv")






















