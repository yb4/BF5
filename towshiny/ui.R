#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
ui <- navbarPage(
  "Homelessness in the US",
  tabPanel("Homelessness Map",
    sidebarLayout(
      sidebarPanel(
        selectInput("state_choose", "Choose a State", choices = c(1, 2, 3)) 
      ),
      mainPanel(leafletOutput("homeless_m"))
    )
))
