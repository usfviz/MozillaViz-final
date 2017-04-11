library(ggplot2)
library(plyr)
library(magrittr)

setwd("~/Desktop/MozillaViz-/")

data <- read.csv("FxDataViz.csv", stringsAsFactors = F)
data$city <- as.factor(data$city)
data$sd <- as.Date(data$sd)
data$appversion <- as.factor(data$appversion)
names(data)[4] <- "count"

germancities <- read.csv("german-cities.csv", stringsAsFactors = F)
germancities$city <- as.factor(germancities$city)

df <- subset(data, city %in% germancities$city)
df$city <- factor(df$city)

ggplot(df, aes(x=sd, y=count, group=appversion, color=appversion)) +
  geom_line()

