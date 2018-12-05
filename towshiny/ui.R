#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(leaflet)
library(shiny)
library(leaflet)

setwd("~/Desktop/BF5/")
ui <- navbarPage(
  "Homelessness in the US",
  tabPanel("Homelessness Map",
    sidebarLayout(
      sidebarPanel(
        selectInput("indicator", " Indicator", c("Total Homeless", "Chronically Homeless Individuals" ,
                                                        'Unsheltered Chronically Homeless Individuals')),
        sliderInput("year", "Year of Interest", 2007, 2016, 2007, step = 1, round = True, ticks = FALSE,
                    animate = TRUE, sep = "")),
      mainPanel(leafletOutput("homeless_m"))
    )
),
tabPanel("HomeLess and drunk",
mainPanel(plotOutput("homless_drinking_plot"))
),
tabPanel("About Us!", mainPanel(
         h1("Yash Baldawa"),
         p("Yash is a Sophomore at UW who's interested in Pursuing Informatics. He can be found on Linkedin here"),
         a("Linkedin", href = "https://www.linkedin.com/in/yashb4/"),
         h1("Tow Mokaramanee"),
         p("Tow is a Sophomore at UW who's interested in Informatics too! He has been extremely enthusiastic about this
           project all the while. He can be found on facebook here"),
         a("Facebook:", href = "https://www.facebook.com/tow2542"),
         h1("Suyash Ahuja"),
         p("Suyash is a sophomore at the UW. Learn more about Suyash here - "),
         a("Facebook:" ,href = "https://www.facebook.com/sy.ahuja")
         )),
tabPanel("Why this?", 
         mainPanel(
          h1("Why Homelessness?"),
          p("Homelessness is a rising problem in Tech Hubs like Seattle, San Francisco, Austin - Texas and 
             Boston - MA, wherein, due to rising costs of living because of an inorganic inflow of money from Tech
            Giants, costs of living start rising which eventually force people to move out to other places. 
            Sometimes, the situation becomes so bad that people can't afford rent and made to live out on streets/
            homeless shelters/ other forms of Refuge which qualify to be homeless according to this data set. 
            We even explore what are sometimes referred to as causes of Homelessness too, like alcohol and drug abuse
            and demostrate if it holds true in case of all states. "),
          br(),
          h1("How does this Visualization Help?"),
          p("This visualization, even though it is on a very small scale, can help government gain leverage over the 
            problem of homelessness by attacking its root cause."),
          p("Weather it is providing affordable housing schemes in very expensive states/neighbourhoods to making the 
            laws more stringent on preventing alochol abuse to prevent homelessness, we go over differnt visualizations
            to see if any of these can be a potential causes of Homelessness")
          ),
         h1("Data Sets in Use"),
         a("Homeless Data Set Kaggle", href = "https://www.kaggle.com/adamschroeder/homelessness/version/2"),
         a("Incomces Data Set Kaggle", href = "https://www.kaggle.com/goldenoakresearch/us-household-income-stats-geo-locations#kaggle_income.csv"),
         a("Drinking Data Sources and States", href = "http://www.healthdata.org/us-health/data-download")
         
         )
)
