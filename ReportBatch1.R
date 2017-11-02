###############################################
##### Bridge Data Cleaning and Graphing #######
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
##### Bridge Data Cleaning and Graphing #######
###############################################

# This script contains multiple reports which clean and graph the data pulled in by the CSM Bridge Reports

rm(list = ls())
library(dplyr)
library(ggplot2)
library(lubridate)
library(RGoogleAnalytics)
library(lazyeval)
library(scales)

# setwd("~/MAIN/BCC/Melinda Reports/Analysis/Data")
setwd("~/MAIN/BCC/EventsTeamReport/")

# Helper functions (and ideas for creating later)
SchoolYear <- function(data){
  data[data$month > 8 | data$month < 5,]
}

## Function to reorder the factor levels in a bar graph

## Dplyr function for summarising and creating new columns

# This program generates the following reports:

## 1) iPad Usage of clubs for the current semester
### Strategic Question 1: Are iPads being used more frequently over time as a result of the efforts of the BCC
### This report displays over time the usage of iPads at club events to check in students. A zero in the kiosk swipe log for an event
### indicates that no iPad was used.
### Strategic Question 2: Are 

# iPads <- read.csv("2015-2018 Club Event Attendees.csv")
iPads <- read.csv("2017-2018 Club Attendance.csv")

#iPads$Date <- as.POSIXct(iPads$Information.Session..Start.Date.Time, format = "%b %d, %Y, %l")
iPads$Date <- as.POSIXct(iPads$Information.Session..Start.Date.Time, format = "%m/%d/%y %H:%M")

iPads$SchoolYear <- ifelse(iPads$Date >= as.Date("2014-09-01") & iPads$Date < as.Date("2015-04-19"), "2014-2015",
                            ifelse(iPads$Date >= as.Date("2015-09-01") & iPads$Date < as.Date("2016-04-19"), "2015-2015",
                                   ifelse(iPads$Date >= as.Date("2016-09-01") & iPads$Date < as.Date("2017-04-19"), "2016-2017",
                                          ifelse(iPads$Date >= as.Date("2017-09-01") & iPads$Date < as.Date("2018-04-19"), "2017-2018",
                                                 "Spring/Summer"))))

iPads$Type <- ifelse(iPads$Information.Session..Flags == "Professional Development Club Event", "Yes", "No")

iPads %>%
  group_by(Information.Session..Club.Event.Title) %>%
  mutate(count = n()) %>% ungroup() -> iPads

iPads$iPad <- ifelse(iPads$count <= 3, "No", "Yes") 

iPadsCurrent <- subset(iPads, SchoolYear == "2017-2018")

iPadsCurrent %>%
  group_by(Information.Session..Club.Event.Title) %>%
  summarise(Event = first(Information.Session..Club.Event.Title), iPad = first(iPad), Date = first(Date), PD = first(Type)) -> iPadsCurrent1

iPadsCurrent1 <- iPadsCurrent1[!(iPadsCurrent1$Date > Sys.time()),]
iPadsCurrent <- iPadsCurrent[!(iPadsCurrent$Date > Sys.time()),]


### Create Previous time period to compare to
### Create previous weeks proportion
iPadsPrevious <- iPadsCurrent1[!(iPadsCurrent1$Date > as.Date(Sys.time())-7),]
ggplot(iPadsPrevious, aes(x = iPad, fill = iPad)) +  
  geom_bar(aes(y = (..count..)/sum(..count..))) + 
  geom_text(aes( label = scales::percent(..count../sum(..count..)), y= ..prop.. ), stat= "count", vjust = 14) +
  xlab("Event Used an iPad") +
  ylab("Percentage") +
  scale_y_continuous(labels = percent) +
  ggtitle("09/01/17 - Previous Week: iPad Usage")

iPadsWeek <- iPadsCurrent1[!(iPadsCurrent1$Date <= as.Date(Sys.time())-7),]
ggplot(iPadsWeek, aes(x = iPad, fill = iPad)) +  
  geom_bar(aes(y = (..count..)/sum(..count..))) + 
  geom_text(aes( label = scales::percent(..count../sum(..count..)), y= ..prop.. ), stat= "count", vjust = 14) +
  xlab("Event Used an iPad") +
  ylab("Percentage") +
  scale_y_continuous(labels = percent) +
  ggtitle("Current Week")

# Join the data tables to add more identifiers
setwd("~/MAIN/BCC/Melinda Reports/Analysis/Data")
FullStudent <- read.csv("Full Student List **ADRIEL**.csv", header = T)
setwd("~/MAIN/BCC/EventsTeamReport/")
Attendees <- iPadsCurrent

colnames(Attendees) <- c("Event Type", "Start Time", 
                         "Club", "Club Event Name", 
                         "Flags", "Name", "Date",
                         "SchoolYear", "Prof.Dev",
                         "count", "iPad.Used")

Attendees$Name <- as.character(Attendees$Name)
FullStudent$Name <- as.character(FullStudent$Name)

AttendeesFull <- left_join(Attendees, FullStudent, by = "Name")


# Select All MA events that have Dojo in the name
selectionCriteria <- c("dojo", "qualtrics")
MAFull <- subset(AttendeesFull, Club == "BYU Marketing Association")
MA <- subset(AttendeesFull, Club == "BYU Marketing Association" & 
               grepl(paste(selectionCriteria, collapse = "|"), `Club Event Name`, ignore.case = T) &
               is.na(Email)==F) %>% filter(`Club Event Name` != "Marketing Association DOJO with Disruptive Advertising")

## Graph how many of each student year goes to the MA DOJO events

### First ORDER THE LEVELS
MA$Class.Level <- factor(MA$Class.Level, levels = c("Freshman", "Sophomore", "Junior", "Senior")) ### This is super valuable!!!


### Create your plot
ggplot(MA, aes(x = Class.Level, fill = Class.Level)) +  
  geom_bar(aes(y = (..count..)/sum(..count..))) + 
  xlab("Class Level") +
  ylab("Percentage") +
  coord_cartesian(ylim = c(0,.6)) +
  scale_y_continuous(labels = percent) +
  geom_text(aes( label = scales::percent(..count../sum(..count..)), y= ..prop.. ), stat= "count", vjust = 25) +
  ggtitle("Proportion of Class Levels in MA DOJOs")


## This report Creates the above proportion graph for each club
Plots <- list()
tmpSub <- list()

### This one was gnarly... It basically creates a proportion plot for each club that had more than one event with attendees
for(i in 1:length(levels(AttendeesFull$Club))){
  tmpSub[[i]] <- subset(AttendeesFull, Club == levels(AttendeesFull$Club)[i]) %>% filter(is.na(Class.Level) != T)
  if(!is.null(nrow(tmpSub[[i]])) & nrow(tmpSub[[i]]) > 2){
    if(length(unique(tmpSub[[i]]$Class.Level)) == 4){
      tmpSub[[i]]$Class.Level <- factor(tmpSub[[i]]$Class.Level, levels = c("Freshman", "Sophomore", "Junior", "Senior"))
    }
    tmpPlot = ggplot(tmpSub[[i]], aes(x = Class.Level, fill = Class.Level)) +  
      geom_bar(aes(y = (..count..)/sum(..count..))) + 
      xlab("Class Level") +
      ylab("Percentage") +
      coord_cartesian(ylim = c(0,1)) +
      scale_y_continuous(labels = percent) +
      geom_text(aes( label = scales::percent(..count../sum(..count..)), y= ..prop.. ), stat= "count", vjust = 2) +
      ggtitle(paste("Proportion of Class Levels in", levels(AttendeesFull$Club)[i]))
    Plots[[paste0("Plot", i)]] <- tmpPlot
  }
}

for(i in 1:length(Plots)){
  try(print(Plots[i]), silent = F)
  ggsave(paste0("Plot", i, ".png"), plot = last_plot())
}

### This one does the same, except it does the count for each event
countByEvents <- AttendeesFull %>% 
  filter(`Club Event Name` != "") %>% filter(Club != "") %>%
  group_by(`Club Event Name`) %>% 
  summarise(Club = first(Club), Event = first(`Club Event Name`), AttendeeSum = n()) %>% ungroup()

countByEvents$AttendeeSum <- with(countByEvents, reorder(AttendeeSum, -AttendeeSum))
countByEvents$Event <- as.factor(as.character(countByEvents$Event))
countByEvents$AttendeeSum <- as.numeric(as.character(countByEvents$AttendeeSum))

str(countByEvents)
Plots1 <- list()
tmpSub <- list()
for(i in 1:length(levels(countByEvents$Club))){
  tmpSub[[i]] <- subset(countByEvents, Club == levels(countByEvents$Club)[i]) %>% filter(is.na(Event) != T) %>%
    filter(AttendeeSum > 2 )
  if(!is.null(tmpSub[[i]]$AttendeeSum) & nrow(tmpSub[[i]]) > 0){
    tmpPlot = ggplot(tmpSub[[i]], aes(x = `Club Event Name`, y= as.factor(AttendeeSum), fill = `Club Event Name`)) +  
      geom_bar(stat = "identity") + 
      xlab("Club Event Name") +
      ylab("Attendees") +
      # geom_text(aes( label = sum(count)), y= count, stat= "count", vjust = 2) +
      ggtitle(paste("Number of Attendees:", levels(AttendeesFull$Club)[i])) +
      theme(text = element_text(size=10), axis.text.x = element_text(angle=45, hjust=1),
            legend.text=element_text(size=6)) 
    Plots1[[paste0("Attendee Report", levels(countByEvents$Club)[i])]] <- tmpPlot
  }
}

for(i in 1:length(Plots1)){
  try(print(Plots1[i]), silent = F)
  ggsave(paste0("Attendee Plot", i), plot = last_plot())
}
rm(Plots1)

Plots1[[4]]


### Percent Professional Development

PD <- iPadsCurrent1

ggplot(PD, aes(x = PD, fill = PD)) +  
  geom_bar(aes(y = (..count..)/sum(..count..))) + 
  geom_text(aes( label = scales::percent(..count../sum(..count..)), y= ..prop.. ), stat= "count", vjust = 8) +
  xlab("Is Professional Development?") +
  ylab("Percentage") +
  scale_y_continuous(labels = percent) +
  ggtitle("09/01/17 - Present: Club Events")

## 2) OCR Job Application time series

OCRapp <- read.csv("OCR Job Application Count **ADRIEL**.csv")
OCRapp$Date <- as.POSIXct(OCRapp$OCR.Schedule.Data..Date, format = "%Y-%m-%d")
OCRapp$Job..Employer <- as.character(OCRapp$Job..Employer)
OCRapp <- OCRapp %>% filter(!grepl("fake", Job..Employer, ignore.case = TRUE)) %>% 
  filter(is.na(OCR.Schedule.Data..ID)==F) %>%
  filter(Job..Employer != "") %>%
  filter(!grepl("STDEV", Job..Employer, ignore.case = TRUE)) %>% 
  .[,-which(colnames(.) %in% c("Job..OCR.Status", "OCR.Schedule.Data..Date"))]
OCRapp$year <- as.factor(year(OCRapp$Date))
OCRapp$week <- week(OCRapp$Date)
OCRapp$month <- month(OCRapp$Date)
OCRapp$months <- months(OCRapp$Date)

### Remove any dates after the current date
OCRapp <- OCRapp[!(OCRapp$Date > Sys.time()),]

### Defines Academic School Years
OCRapp$SchoolYear <- ifelse(OCRapp$Date >= as.Date("2014-09-01") & OCRapp$Date < as.Date("2015-04-19"), "2014-2015",
                            ifelse(OCRapp$Date >= as.Date("2015-09-01") & OCRapp$Date < as.Date("2016-04-19"), "2015-2015",
                            ifelse(OCRapp$Date >= as.Date("2016-09-01") & OCRapp$Date < as.Date("2017-04-19"), "2016-2017",
                            ifelse(OCRapp$Date >= as.Date("2017-09-01") & OCRapp$Date < as.Date("2018-04-19"), "2017-2018",
                            "Spring/Summer"))))

### Creates monthly and weekly averages for Job applications
OCRapp <- OCRapp %>%
  group_by(year, month) %>%
  mutate(MonthlyAve = mean(Job..Applicants), MonthlySum = sum(Job..Applicants)) %>%
  ungroup() %>% group_by(year, week) %>%
  mutate(WeeklyAve = mean(Job..Applicants), WeeklySum = sum(Job..Applicants)) %>%
  ungroup() %>% group_by(SchoolYear) %>% 
  mutate(AvgAppsSchoolYear = mean(Job..Applicants))

### Removes any data outside of the school year (in between May and August)
OCRSchoolYear <- SchoolYear(OCRapp)

### Graphs!

anova(aov(Job..Applicants ~ SchoolYear, data=OCRapp))
fit <- lm(WeeklyAve ~ SchoolYear, data = OCRapp)
summary(fit)

ggplot(OCRapp, aes(x = SchoolYear, y = Job..Applicants, col = SchoolYear)) +
  geom_boxplot() +
  ggtitle("Job Applications per School Year")

ggplot(OCRapp, aes(x = Date, y = WeeklySum, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Job Applications") +
  ggtitle("Total Job Application per Week: 2014 - 2018")

ggplot(OCRapp, aes(x = Date, y = WeeklyAve, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Job Applications") +
  ggtitle("Weekly Average Applications per Job: 2014 - 2018")

ggplot(OCRapp, aes(x = Date, y = MonthlySum, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Job Applications") +
  ggtitle("Total Job Application per Month: 2014 - 2018")

ggplot(OCRapp, aes(x = Date, y = MonthlyAve, group = year, color = year)) + 
  geom_line() +
  ylab("Job Applications") +
  ggtitle("Monthly Average Applications per Job: 2014 - 2018")

OCRapp1 <- OCRapp[-which(OCRapp$SchoolYear=="Spring/Summer" | is.na(OCRapp$SchoolYear)==T),]

ggplot(OCRapp1, aes(x = SchoolYear, y = Job..Applicants, fill = year)) + 
  geom_bar(stat = "identity", position = "dodge") +
  ylab("Job Applications") +
  ggtitle("Total Job Applications for Each School Year: 2014-2018")


ggplot(OCRapp1, aes(x = month, y = MonthlyAve, group = SchoolYear, color = year)) + 
  geom_line() +
  ylab("Job Applications") +
  ggtitle("Monthly Average Applications per Job: 2014 - 2018")


OCRapp %>%
  group_by(SchoolYear) %>%
  summarize(MeanAppsPerJob = mean(Job..Applicants))

####  Conclusion: The total amount of applications is decreasing YoY, although the average applicants per job is increasing


## 3) Company Info Session Attendance time series analysis

InfoSess <- read.csv("Company info sessions **ADRIEL**.csv")
InfoSess$Date <- as.POSIXct(InfoSess$Start.Date.Time, format = "%b %d, %Y, %l")
InfoSess$year <- as.factor(year(InfoSess$Date))
InfoSess$week <- week(InfoSess$Date)
InfoSess$month <- month(InfoSess$Date)
InfoSess$months <- months(InfoSess$Date)
InfoSess$day <- day(InfoSess$Date)

### Filter out values by criteria
InfoSess <- InfoSess %>% filter(!grepl("fake", Organization.Name, ignore.case = TRUE)) %>% 
  filter(Organization.Name!="") %>%
  filter(!grepl("Bilbo", Organization.Name, ignore.case = TRUE)) %>% 
  filter(!grepl("BYU", Organization.Name, ignore.case = TRUE)) %>% 
  filter(!grepl("ALPFA", Organization.Name, ignore.case = TRUE)) %>% 
  filter(!grepl("PreMa", Organization.Name, ignore.case = TRUE)) %>% 
  .[,-which(colnames(.) %in% c("Symplicity.Information.Session.ID", "Information.Session.Type"))]

### Only consider events with one or more attendee
InfoSess$Attendees <- InfoSess$Kiosk.Swipe.Log..Information.Sesssion.count.
InfoSess1 <- subset(InfoSess, Attendees > 0)

InfoSess1$SchoolYear <- ifelse(InfoSess1$Date >= as.Date("2014-09-01") & InfoSess1$Date <= as.Date("2015-04-19"), "2014-2015",
                            ifelse(InfoSess1$Date >= as.Date("2015-09-01") & InfoSess1$Date <= as.Date("2016-04-19"), "2015-2015",
                                   ifelse(InfoSess1$Date >= as.Date("2016-09-01") & InfoSess1$Date <= as.Date("2017-04-19"), "2016-2017",
                                          ifelse(InfoSess1$Date >= as.Date("2017-09-01") & InfoSess1$Date <= as.Date("2018-04-19"), "2017-2018",
                                                 "Spring/Summer"))))


InfoSess1 <- InfoSess1 %>%
  group_by(year, month) %>%
  mutate(MonthlyAve = mean(Attendees), MonthlySum = sum(Attendees)) %>%
  ungroup() %>% group_by(year, week) %>%
  mutate(WeeklyAve = mean(Attendees), WeeklySum = sum(Attendees)) %>%
  ungroup() %>% group_by(Organization.Name) %>% 
  mutate(AvgAttendOrg = mean(Attendees)) %>% 
  ungroup() %>% group_by(SchoolYear) %>% 
  mutate(AvgAttendSchoolYear = mean(Attendees)) %>%
  ungroup() %>% group_by(year, day) %>%
  mutate(AvgAttendDay = mean(Attendees))
  
### Graphs!

anova(aov(Attendees ~ SchoolYear, data=InfoSess1))
fit <- lm(Attendees ~ SchoolYear, data = InfoSess1)
summary(fit)

InfoSess1 <- InfoSess1[which(InfoSess1$Attendees < 125),]
InfoSess2 <- InfoSess1[which(InfoSess1$SchoolYear!="Spring/Summer"),]

ggplot(InfoSess2, aes(x = SchoolYear, y = Attendees, col = SchoolYear)) +
  geom_boxplot() +
  ggtitle("Information Session Attendees per School Year")

ggplot(InfoSess1, aes(x = Date, y = WeeklySum, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Attendees") +
  ggtitle("Total Info Session Attendees per Week: 2014 - 2018")

ggplot(InfoSess1, aes(x = Date, y = WeeklyAve, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Attendees") +
  ggtitle("Weekly Average Attendees per Info Session: 2014 - 2018")

ggplot(InfoSess2, aes(x = Date, y = AvgAttendDay, group = year, color = SchoolYear)) + 
  geom_line() +
  ylab("Attendees") +
  ggtitle("Daily Average Attendees per Info Session: 2014 - 2018")

ggplot(InfoSess2, aes(x = Date, y = AvgAttendDay, group = SchoolYear, col = SchoolYear)) + 
  geom_line(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  ylab("Attendees") +
  ggtitle("Daily Average Attendees per Info Session: 2014 - 2018")

InfoSess1 %>%
  group_by(SchoolYear) %>%
  summarize(MeanAttendeesPerInfoSess = mean(Attendees))


ggplot(InfoSess2, aes(x = Attendees, fill = year)) +
  scale_color_manual(values = c("#89C5DA", "#DA5724", "#74D944", "#CE50CA")) +
  geom_histogram(binwidth = 10, position = "dodge") +
  facet_grid(.~ SchoolYear) +
  ggtitle("Spread of Attendees for Each School Year: 2014-2018")

## 4) CareerLaunch Traffic time series analysis


