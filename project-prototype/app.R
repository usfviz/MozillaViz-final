list.of.packages <- c("D3partitionR", "jsonlite")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(shiny)
library(D3partitionR)
library(jsonlite)

ui <- navbarPage("MozillaViz",
                 tabPanel("About", htmlOutput("about")),
                 tabPanel("Firefox Versions Map", htmlOutput("inc")),
                 navbarMenu("Firefox OS Charts",
                            tabPanel("Circle Tree Map", D3partitionROutput("circleTreeMap", width = 800)),
                            tabPanel("Sunburst", D3partitionROutput("sunburst", width = 800)),
                            tabPanel("Partition Chart", D3partitionROutput("partitionChart", width = 800)),
                            tabPanel("Tree Map", D3partitionROutput("treeMap", width = 800)),
                            tabPanel("Collapsible Tree", D3partitionROutput("collapsibleTree", width = 800))
                 ),
                 footer = " Built by Connor Ameres, Andre Duarte",
                 inverse = T
)


server <- function(input, output, session) {
  
  output$about <- renderText({
    paste0(
      "<h1>Description of the data set</h1>",
      "<p>The data was collected from Mozilla's internal tables, using a custom script in Spark. ",
      "The data is anonymized and grouped so that there are no privacy issues of uniquely identifying profiles. ",
      "There are two json files that we use to plot our data.</p>",
      
      "<h2>Firefox version distribution on a map</h2>",
      "<p>The file <kbd>main_cities_size.json</kbd> contains monthly aggregated data for select cities in Europe concerning the distribution of Firefox versions. ",
      "For each city, we have the latitude and longitude to plot on the map, the relative proportion of users in that city versus everywhere else to define the size of the point on the map, and the relative proportions of Firefox versions within that city to build the pie charts. ",
      "Using <em>D3.js</em> (which we put back into Shiny in order to include it with the other visualizations), we use the above data to create pie charts with Firefox version distributions for each city and place them correspondingly on an interactive map. ",
      "The size of the pie charts shows the 'importance' of each city by number of monthly users. ",
      "In addition, the user can hover on a pie chart to easily get quantified information about the selected city.</p>",
      
      "<h2>Firefox Operating Systems hierarchical distribution</h2>",
      "<p>The file <kbd>os2.json</kbd> contains monthly aggregated data for select cities in Europe concerning the distribution of OS versions. ",
      "For each city, we have the main OS (Windows_NT, Darwin, Linux), the minor OS version, and the count of occurrences. ",
      "Using a <em>D3.js</em> library in R (D3PartitionR), we are able to create several hierarchical plots to visualize this data: a circle tree map, a sunburst map, a partition chart, a tree map, and a collapsible tree. ",
      "The user can hover and/or click through the data and explore the sub-partitions of the data within each country, city, and OS.</p>",
      
      "<h2>Discussion</h2>",
      "<p>Since part of this project (the map) was built in D3, and the other (the hierarchical distribution) in Shiny (albeit using a D3 wrapper library), it has proven difficult to successfully integrate both into a single Shiny app that works as expected. ",
      "One of the main issues we have right now is that only one of the visualizations will work if all are included. ",
      "The trick for now is to comment out the map output in the app.R file before running, which is not a good fix.</p>",
      "<p>Another difficulty, on both parts of the project, was to integrate a time selector. ",
      "In both cases, this would cause the entire visualization to stop responding and had to be dropped. ",
      "However, the overall look of the project is very similar to what we had envisioned.</p>"
    )
  })
  
  getPage<-function() {
    return(tags$iframe(src = "index.html",
                       style = "width:100%;",
                       frameborder = "0",
                       id = "iframe",
                       height = "800px"))
  }
  
  output$inc <- renderUI({
    getPage()
  })
  
  os2 <- fromJSON("os2.json", simplifyDataFrame = T)
  os2 <- subset(os2, sd == "2016-09")
  os2$path_str <- paste(paste("World", os2$country, os2$city, os2$os, os2$os_version, sep = "/"))
  os2$path <- strsplit(os2$path_str, "/")
  os2$cnt <- round(os2$cnt/sum(os2$cnt)*100, 3)
  
  output$circleTreeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "circleTreeMap",
                 trail = T)
  })
  
  output$partitionChart <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "partitionChart",
                 trail = T)
  })
  
  output$treeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "treeMap",
                 trail = T)
  })
  
  output$sunburst <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "sunburst",
                 trail = T)
  })
  
  output$collapsibleTree <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "collapsibleTree",
                 trail = T,
                 specificOptions = list(bar=T))
  })
}

addResourcePath('www', '.')
addResourcePath('map', '.')
addResourcePath('static', '.')

shinyApp(ui = ui, server = server)

