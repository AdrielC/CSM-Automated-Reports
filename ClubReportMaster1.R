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

### Clean up the Last Name column by removing everything but the LAST name (everything after the last space)
attendees$name <- NA
for(i in 1:nrow(attendees)){
  attendees[i,"name"] <- paste(attendees[i, "FirstName"], tail(unlist(strsplit(attendees[i,"LastName"], " ")), n = 1))
}

### Clean up the Last.Name column in master.club with the same method as above
master.club$name <- NA
master.club$Last.Name <- as.character(master.club$Last.Name)
master.club$First.Name <- as.character(master.club$First.Name)
for(x in 1:nrow(master.club)){
  master.club[x,"name"] <- paste(master.club[x, "First.Name"], tail(unlist(strsplit(master.club[x,"Last.Name"], " ")), n = 1))
}

### Identify the records (rows) in the attendee list that are not present in the Master club list
non.members <- subset(attendees, !(attendees$name %in% master.club$name)) %>%
  filter(LastName != "NA")



### Write out the non-member list to a csv!
write.csv(non.members, "non-member event attendees.csv")






















