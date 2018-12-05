#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

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