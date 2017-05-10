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
                            tabPanel("Circle Tree Map",
                                     mainPanel(D3partitionROutput("circleTreeMap")),
                                     sidebarPanel(width = 3, htmlOutput("circleAbout")), width = 800),
                            tabPanel("Sunburst",
                                     mainPanel(D3partitionROutput("sunburst")),
                                     sidebarPanel(width = 3, htmlOutput("sunburstAbout")), width = 800),
                            tabPanel("Partition Chart",
                                     mainPanel(D3partitionROutput("partitionChart")),
                                     sidebarPanel(width = 3, htmlOutput("partitionAbout")), width = 800),
                            tabPanel("Tree Map",
                                     mainPanel(D3partitionROutput("treeMap")),
                                     sidebarPanel(width = 3, htmlOutput("treeAbout")), width = 800),
                            tabPanel("Collapsible Tree",
                                     mainPanel(D3partitionROutput("collapsibleTree")),
                                     sidebarPanel(width = 3, htmlOutput("collapsibleAbout")), width = 800)
                 ),
                 footer = "Built by Connor Ameres, Andre Duarte",
                 inverse = T
)


server <- function(input, output, session) {
  
  output$about <- renderText({
    paste0(
      "<h1>Project objective</h1>",
      "<p>This app allows for a visualization of Firefox usage in select cities in Europe. ",
      "We wanted to get and show other data from Mozilla that we don't usually use in our practicum.</p>",
      
      "<h1>Description of the data set</h1>",
      "<p>The data was collected from Mozilla's internal tables, using a custom script in Spark. ",
      "The data is anonymized and grouped so that there are no privacy issues of uniquely identifying profiles. ",
      "There are two json files that we use to plot our data.</p>",
      
      "<h2>Firefox version distribution on a map</h2>",
      "<p>The file <kbd>main_cities_size.json</kbd> contains monthly aggregated data for select cities in Europe concerning the distribution of Firefox versions. ",
      "For each city, we have the latitude and longitude to plot on the map, the relative proportion of users in that city versus everywhere else to define the radius of the charts on the map, and the relative proportions of Firefox versions within that city to build the slices of the pie charts. ",
      "Using <em>D3.js</em> and <em>Leaflet</em> in a standalone HTML page (which we later embed into the Shiny application with IFrames), we use the above data to create pie charts with Firefox version distributions for each city and place them correspondingly on an interactive map. ",
      "The radius of the pie charts shows the 'importance' of each city by number of monthly users. ",
      "In addition, the user can hover on a pie chart to easily get quantified information about the selected city.</p>",
      
      "<h2>Firefox Operating Systems hierarchical distribution</h2>",
      "<p>The file <kbd>os2.json</kbd> contains monthly aggregated data for select cities in Europe concerning the distribution of OS versions. ",
      "For each city, we have the main OS (Windows_NT, Darwin, Linux), the minor OS version, and the count of occurrences. ",
      "Using a <em>D3.js</em> library in R (D3PartitionR), we are able to create several hierarchical plots to visualize this data: a circle tree map, a sunburst map, a partition chart, a tree map, and a collapsible tree. ",
      "The user can hover and/or click through the data and explore the sub-partitions of the data within each country, city, and OS.</p>",
      
      "<h2>Issues</h2>",
      "<p>The application currently has an issue with navigating between the charts. If the navbar stops working please refresh the application/browser</p>",
      
      "<h2>Discussion</h2>",
      "<p>Since part of this project (the map) was built in D3, and the other (the hierarchical distribution) in Shiny (albeit using a D3 wrapper library), it has proven difficult to successfully integrate both into a single Shiny app that works as expected. ",
      "However, we were able to do this by embedding the html (that calls the javascript code) within an iframe directly in Shiny. ",
      "It's not the most elegant solution (coding-wise), but looks and performs really well in the end.</p>",
      "<p>Another difficulty, on both parts of the project, was to integrate a time selector. ",
      "In both cases, this would cause the entire visualization to stop responding, resulting in poor user experience and had to be dropped. ",
      "However, the overall look of the project is very similar to what we had originally envisioned.</p>",
      "<p>Based on the prototype feedback, we added text descriptions for each plot as well as a landing page that explains the project a little bit. ",
      "The descriptions for the maps/charts are very similar since they refer to the same data.</p>"
    )
  })
  
  about <- paste0(
    "<p>Each set is partitioned by country, city, OS name, and OS version. ",
    "Hovering over a sub-partition shows information about the current cell. ",
    "In particular, the relative importance to the previous partition is shown (<em>From previous step</em>) as well as the total relative importance of the selected subpartition (<em>From the beginning</em>). ",
    "</p>"
  )
  
  output$circleAbout <- renderText({
    paste0(
      "<h2>Circle Tree Map</h2>",
      about,
      "<p>This map makes it easy to see every subdivision in a simple and intuitive manner. ",
      "All the cells are hoverable and color-matched without needing to 'dive deeper' into the map. ",
      "Finally, the user can click on any subpartition to 'zoom in' and see the information in a more contextualized way.",
      "</p>"
    )
  })
  
  output$sunburstAbout <- renderText({
    paste0(
      "<h2>Subburst</h2>",
      about,
      "<p>This map shows all the partitions based on proportions. ",
      "Each additional level's size is relative to the previous. ",
      "Comparisons between levels are difficult, but those within levels are manageable.",
      "</p>"
    )
  })
  
  output$partitionAbout <- renderText({
    paste0(
      "<h2>Partition Chart</h2>",
      about,
      "<p>This chart makes it very easy to see the importance of each subpartition relative to the whole. ",
      "They are ordered by size (ie number of active profiles), so the user can quickly understand which country/city/OS/version has more users. ",
      "The user can click on any subpartition to 'zoom in' and see the information in a more contextualized way.",
      "</p>"
    )
  })
  
  output$treeAbout <- renderText({
    paste0(
      "<h2>Tree Map</h2>",
      about,
      "<p>This chart makes it very easy to see the importance of each subpartition relative to the whole. ",
      "The cells are ordered by size (ie number of active profiles), so the user can quickly understand which country/city/OS/version has more users. ",
      "The user can click on any subpartition to 'zoom in' and reveal more information about the selected partition. ",
      "In addition to the size of the cells, the color gradient is another source of information that codes this data.",
      "</p>"
    )
  })
  
  output$collapsibleAbout <- renderText({
    paste0(
      "<h2>Collapsible Tree Map</h2>",
      about,
      "<p>This map allows for a more selective and interactive display of the data. ",
      "The user can click through the path that they are interested in, and only this information is shown. ",
      "The size of the points depends on the number of users, but this information is not as clear as possible, since the points are small and far apart from each other.",
      "</p>"
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

