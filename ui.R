#In this part of the project, we build the UI to present the widgets and the 
#visualiztions expected in this assignment

library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel <- ("UFO SIGHTINGS DATA"),
  tabsetPanel(
    tabPanel("Homeless Data By American States",
             fluid = TRUE,
             sidebarLayout(
               sidebarPanel(
                 selectInput("state_select", "Choose a State",
                             choices = list("Alabama" = "Alabama","Alaska" = "AK",
                                            "Arizona" = "AZ", "Arkansas" = "AR", 
                                            "California" = "CA", "Colorado"= "CO", "Connecticut" = "CT",
                                            "Delaware" = "DE", "Flodrida" = "FL", "Georgia" = "GA",
                                            "Hawaii" = "HI", "Idaho" = "ID", "Illnois" = "IL",
                                            "Indiana" = "IN", "Iowa" = "IA", "Kansas" = "KS",
                                            "Kentucky" = "KY","Louisiana" = "LA", "Maine" = "ME",
                                            "Maryland" = "MD", "Massachusetts" = "MA", 
                                            "Michigan" = "MI", "Minnesota" = "MN", "Mississippi" = "MS",
                                            "Missouri" = "MO", "Montana" = "MT", "Nebraska" = "NE",
                                            "Nevada" = "NV", "New Hampshire" = "NH", "New Jersey" = "NJ",
                                            "New Mexico" = "NM","New York" = "NY", "North Carolina" = "NC",
                                            "North Dakota" = "ND", "Ohio" = "OH", "Oklahoma" = "OK",
                                            "Oregon" = "OR", "Pennsylvania" = "PA", "Rhode Island" = "RI",
                                            "South Carolina" = "SC", "South Dakota" = "SD", 
                                            "Tennessee" = "TN","Texas" = "TX", "Utah" = "UT",
                                            "Vermont" = "VT", "Virginia" = "VA", "Washington" = "WA",
                                            "West Virginia" = "WV", "Wisconsin" = "WI", "Wyoming" = "WY", 
                                            "Washington DC" = "DC"),
                             selected = "WA"
                 )
               ),
               
               # This is the main panel, displaying the visualization presenting most commonly occuring shapes in that part
               # of US and displaying beneath it, the total UFO Observations recorded in that state
               mainPanel(
                 plotOutput("states")
               )
             ))
  )
)

