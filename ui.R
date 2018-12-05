library(shiny)
library(leaflet)

ui <- navbarPage(
  "Homelessness in the US",
  tabPanel("Homelessness Map",
           sidebarLayout(
             sidebarPanel(
               selectInput("indicator", " Indicator", c("Total Homeless", "Chronically Homeless Individuals" ,
                                                        'Unsheltered Chronically Homeless Individuals')),
               sliderInput("year", "Year of Interest", 2007, 2016, 2016, step = 1, round = True, ticks = FALSE, sep = "")),
             mainPanel(leafletOutput("homeless_m"))
           )
  ))