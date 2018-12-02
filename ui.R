library(shiny)
library(ggplot2)

ui <- navbarPage(
  
  # App title ----
  "Homelessness vs Causes",
  tabPanel("Potential Cause vs Effect per state",
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select the random distribution type ----
      selectInput("state_choose", "Choose a State",
                  choices = list("Alabama" = "AL","Alaska" = "AK",
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
      ),
      
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("HomelessNess Per State", plotOutput("HS_state")),
                  tabPanel("HS_vs_Drugs_and_drinking", plotOutput("HS_D_and_D")),
                  tabPanel("HS_vs_Increase_in_wage_rent", plotOutput("HS_vs_Wage")),
                  tabPanel("HomelessNess_per_state", plotOutput("HS_text_per_state"))
      )
      
    )
  )
  )
)
)