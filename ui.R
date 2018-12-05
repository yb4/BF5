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

state_name <- append(state.name, "District of Columbia", after = 8) 

ui <- navbarPage(
  "Homelessness in the US",
  tabPanel("Homeless Population Map",
           sidebarLayout(
             sidebarPanel(
               selectInput("indicator", " Indicator", c("Total Homeless", "Chronically Homeless Individuals" ,
                                                        'Unsheltered Chronically Homeless Individuals')),
               sliderInput("year", "Year of Interest", 2007, 2016, 2016, step = 1, round = True, ticks = FALSE, sep = "")),
             mainPanel(leafletOutput("homeless_m"))
           )
  ), 
  tabPanel("State Rankings", 
           sidebarLayout(
             sidebarPanel(
               selectInput("rank_indicator", "Indicator", c("Total Homeless", "Chronically Homeless Individuals" ,
                                                          'Unsheltered Chronically Homeless Individuals')),
               sliderInput("rank_year", "Year of Interest", 2007, 2016, 2016, step = 1, round = True, ticks = FALSE, sep = "")
             ),
           mainPanel(tableOutput("ranking"))
           ) 
              
  ),
  tabPanel("Homeless Population by State",
           sidebarLayout(
             sidebarPanel(
               selectInput("state", "State of Interest", state_name)),
             mainPanel(plotOutput("by_state"))
           )
  )
  
)

