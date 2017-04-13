library(ggplot2)
library(plyr)
library(magrittr)
library(scales)
library(data.table)

setwd("~/Desktop/MozillaViz-/")

data <- read.csv("FxDataViz.csv", stringsAsFactors = F)
data$city <- as.factor(data$city)
data$sd <- as.Date(data$sd)
data$appversion <- as.factor(data$appversion)
names(data)[4] <- "count"

# That's way too much data. Let's remove some cities
germancities <- read.csv("german-cities.csv", stringsAsFactors = F)
germancities$city <- as.factor(germancities$city)

df <- subset(data, city %in% germancities$city)
df$city <- factor(df$city)

# Convert to data.table
DF <- data.table(df)
DF[, totDay := sum(count), by = list(city, sd)]
DF[, pctDay := count/totDay, by = list(city, sd)]

# That's better. Let's plot and see what it looks like

ggplot(DF, aes(x=sd, y=pctDay, group=interaction(appversion, city), color=appversion)) +
  geom_line()

# This is too messy. Let's remove some appversions
table(DF$appversion)

# We can remove app versions 39, 40, and 51 for starters
DF <- subset(DF, appversion %in% 46:50)
DF$appversion <- factor(DF$appversion)

ggplot(DF, aes(x=sd, y=count, group=appversion, color=appversion)) +
  geom_line() +
  facet_grid(appversion~.) +
  scale_y_continuous(labels = comma)

##### Let's try something else
cities <- c("Berlin", "Munich", "Frankfurt", "Stuttgart",
            "Essen", "Dortmund")
subDF <- subset(DF, city %in% cities)

ggplot(subDF, aes(x=sd, y=pctDay, group=interaction(appversion, city))) +
  geom_line(aes(color=appversion)) + 
  geom_point(aes(shape=city, color=appversion))











