library(dplyr); library(fcuk)
setwd("~/MAIN/BCC/RESTReporting/")
rm(list=ls())

full.student <- read.csv("FullStudentList.csv")

sample <- sample_frac(full.student, size = .3) %>% select(First.Name, Last.Name, Email)

write.csv(sample, file = "Full Business Student List.csv", row.names = F)
