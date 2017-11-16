###############################################
###### Club Data Cleaning and Graphing ########
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
###### Club Data Cleaning and Graphing ########
###############################################

# Clear out your Environment
rm(list = ls())

# Set your working directory to your central folder that contains all of the data you need
setwd("~/MAIN/BCC/RESTReporting/")

# Set this for easily installing and loading packages. This is very useful when sharing code
if(!("easypackages" %in% installed.packages()[,"Package"])) install_packages("easypackages"); library(easypackages)

# Create a list of your packages as strings and then install/load as needed
list.of.packages <- c("dplyr", "ggplot2","lubridate", "lazyeval", "scales", "fcuk", "RGoogleAnalytics", "ggfortify", "forecast", "fpp2", "ISLR", "leaps")
packages(list.of.packages, prompt = F)

# Helper functions (and any ideas for creating later)
SchoolYear <- function(data){
  data[data$month > 8 | data$month < 5,]
}

# Read in the Attendee data for all events

iPads <- read.csv("~/MAIN/BCC/Club\ data/Full data/2017-2018\ Club\ Event\ Attendees.csv")
# iPads <- read.csv("2017-2018 Club Attendance.csv")

#iPads$Date <- as.POSIXct(iPads$Information.Session..Start.Date.Time, format = "%b %d, %Y, %l")
iPads$Date <- as.POSIXct(iPads$Information.Sesssion..Start.Date.Time, format = "%b %d, %Y, %I:%M %p")

iPads$SchoolYear <- ifelse(iPads$Date >= as.Date("2014-09-01") & iPads$Date < as.Date("2015-04-19"), "2014-2015",
                           ifelse(iPads$Date >= as.Date("2015-09-01") & iPads$Date < as.Date("2016-04-19"), "2015-2015",
                                  ifelse(iPads$Date >= as.Date("2016-09-01") & iPads$Date < as.Date("2017-04-19"), "2016-2017",
                                         ifelse(iPads$Date >= as.Date("2017-09-01") & iPads$Date < as.Date("2018-04-19"), "2017-2018",
                                                "Spring/Summer"))))

iPads %>%
  group_by(Information.Sesssion..Club.Event.Title) %>%
  mutate(count = n()) %>% ungroup() -> iPads

iPads$iPad <- ifelse(iPads$count <= 3, "No", "Yes") 

iPadsCurrent <- subset(iPads, SchoolYear == "2017-2018")
iPadsCurrent <- iPadsCurrent[!(iPadsCurrent$Date > Sys.time()),]

FullStudent <- read.csv("~/MAIN/BCC/Club\ data/Full\ Data/Full Student List **ADRIEL**.csv", header = T)
Attendees <- iPadsCurrent

colnames(Attendees) <- c("StudentName", "StartDate", 
                         "Club", "ClubEventName", 
                         "StudentID", "Email", "Date",
                         "SchoolYear", "count", "iPad.Used")

Attendees$Name <- as.character(Attendees$StudentName)
FullStudent$Name <- as.character(FullStudent$Name)

AttendeesFull <- left_join(Attendees, FullStudent, by = "Name")

Plots <- list()
tmpSub <- list()

countByEvents <- AttendeesFull %>% 
  filter(ClubEventName != "") %>% filter(Club != "") %>%
  group_by(ClubEventName) %>% 
  summarise(Club = first(Club), Event = first(ClubEventName), AttendeeSum = n()) %>% ungroup()

countByEvents$AttendeeSum <- with(countByEvents, reorder(AttendeeSum, -AttendeeSum))
countByEvents$Event <- as.factor(as.character(countByEvents$Event))
countByEvents$AttendeeSum <- as.numeric(as.character(countByEvents$AttendeeSum))

setwd("/Volumes/share/Business Career Center/Operations Team/03 Brand Management/Brand Strategy/Adriel Casellas/Club data/PDF 11-14-17/Club Charts/")

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
    Plots[[paste0("Class Level", levels(countByEvents$Club)[i])]] <- tmpPlot
  }
}

for(i in 1:length(Plots)){
  try(print(Plots[i]), silent = F)
  ggsave(paste0(names(Plots)[i], i, ".png"), plot = last_plot())
}


### This one does the same, except it does the count for each event
setwd("/Volumes/share/Business Career Center/Operations Team/03 Brand Management/Events Team/02 Meeting Material/Club Meeting Material/Powerpoints/2017-2018/Data Charts for 2017-2018")
Plots1 <- list()
tmpSub <- list()
for(i in 1:length(levels(countByEvents$Club))){
  tmpSub[[i]] <- subset(countByEvents, Club == levels(countByEvents$Club)[i]) %>% filter(is.na(Event) != T) %>%
    filter(AttendeeSum > 2 )
  if(!is.null(tmpSub[[i]]$AttendeeSum) & nrow(tmpSub[[i]]) > 0){
    tmpPlot = ggplot(tmpSub[[i]], aes(x = ClubEventName, y= as.factor(AttendeeSum), fill = ClubEventName)) +  
      geom_bar(stat = "identity") + 
      xlab("Club Event Name") +
      ylab("Attendees") +
      # geom_text(aes( label = sum(count)), y= count, stat= "count", vjust = 2) +
      ggtitle(paste("Number of Attendees:", levels(AttendeesFull$Club)[i])) +
      theme(text = element_text(size=8), axis.text.x = element_text(angle=70, hjust=1),
            legend.text=element_text(size=6), plot.title = element_text(size = 10, face = "bold")) 
    Plots1[[paste0("Attendee Report ", levels(countByEvents$Club)[i])]] <- tmpPlot
  }
}

for(i in 1:length(Plots1)){
  try(print(Plots1[i]), silent = F)
  ggsave(paste0(names(Plots1)[i], i, ".png"), plot = last_plot())
}

### Now, lets look at the correlation between Careerlaunch Traffic and club attendance
source("~/MAIN/MA/Analytics Dojo/setup.R")

Q.Users2017 <- Init(table.id = "ga:107460317",
                    start.date = "2017-09-01", # GA will return data for the day before this date
                    end.date = as.Date(Sys.time()), # This returns the current date
                    metrics = "ga:users,ga:avgTimeOnPage, ga:sessions, ga:avgSessionDuration, ga:pageviews", # These are the site measurements you want to examine
                    dimensions = "ga:date", # This is your date column
                    segment = "sessions::condition::ga:exitPagePath=@events",
                    max.results = 10000)

# Step Four: Execute the Query (the queries you just made)

## Build the query so Google Analytics can read it
ga.query <- QueryBuilder(Q.Users2017)

## Fire the Query to the GA API, and reorder the result. Each query will take some time depending on your time interval
ga.df <- GetReportData(ga.query, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df <- ga.df[order(as.numeric(ga.df$date)),] # Reorder by date descending


## Create a timeseries of club event attendance
AttendeesFull %>% 
  filter(ClubEventName != "") %>% filter(StudentName != "") %>%
  group_by(StartDate) %>% 
  summarise(AttendeeSum = n(), Date = first(StartDate)) %>% ungroup() -> countByDay

countByDay$Date <- as.POSIXct(countByDay$Date, format = "%b %d, %Y, %I:%M %p")
ga.df$Date <- as.POSIXct(ga.df$date, format = "%Y%m%d")

countByDay$Date <- round_date(countByDay$Date, "day")
ga.df$Date <- round_date(ga.df$Date, "day")

Joined <- left_join(ga.df, countByDay, by = "Date")

### Create your linear models
par(mfrow=c(2,2))
plot(Joined$AttendeeSum, Joined$users)
plot(Joined$AttendeeSum, Joined$avgTimeOnPage)
plot(Joined$AttendeeSum, Joined$sessions)
hist(Joined$AttendeeSum)

RegData <- select(Joined, users, avgTimeOnPage, sessions, avgSessionDuration, pageviews, AttendeeSum) %>%
  subset(!(is.na(AttendeeSum)))

leap <- regsubsets(AttendeeSum~., data = RegData, nbest = 10)
leapsum <- summary(leap)
par(mfrow=c(1,1))
plot(leap, scale = 'adjr2')

mod1 <- lm(AttendeeSum ~ avgSessionDuration + pageviews, data = RegData)
summary(mod1)

RegData1 <- RegData
RegData1$pageviews <- lag(RegData1$pageviews, n = 1L)
RegData1$avgSessionDuration <- lag(RegData1$avgSessionDuration, n = 1L)
mod2 <- lm(AttendeeSum ~ pageviews + avgSessionDuration, data = RegData1)
summary(mod2)

