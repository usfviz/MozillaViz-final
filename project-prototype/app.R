library(shiny)
library(D3partitionR)
library(jsonlite)

ui <- navbarPage("MozillaViz",
                 tabPanel("Firefox Versions Map", htmlOutput("inc")),
                 navbarMenu("Firefox OS Charts",
                            tabPanel("Circle Tree Map", D3partitionROutput("circleTreeMap", width = 800)),
                            tabPanel("Sunburst", D3partitionROutput("sunburst", width = 800)),
                            tabPanel("Partition Chart", D3partitionROutput("partitionChart", width = 800)),
                            tabPanel("Tree Map", D3partitionROutput("treeMap", width = 800)),
                            tabPanel("Collapsible Tree", D3partitionROutput("collapsibleTree", width = 800))
                 ),
                 footer = "Built by Connor Ameres, Andre Duarte",
                 inverse = T
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  getPage<-function() {
    return(tags$iframe(src = "index.html",
                       style = "width:100%;",
                       frameborder = "0",
                       id = "iframe",
                       height = "600px"))
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
addResourcePath('static', '.')

# Run the application 
shinyApp(ui = ui, server = server)

