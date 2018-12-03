#Setting up libraries required for this task
library(shiny)
library(dplyr)
library(data.table)
library(ggplot2)
library(R.utils)
setwd("~/Desktop/BF5/")
homeless_by_state <- data.table :: fread("data/Homelessness.csv", sep = ",", stringsAsFactors = FALSE)
total_homeless <- homeless_by_state %>% filter(Measures == "Total Homeless")
write.csv(total_homeless, "data/total_homeless.csv", row.names = TRUE)

# Help needed here, trying to calculate the sum total of the Homeless Population
# gives me the nrow() instead
#sum_total_homeless <- sum(total_homeless, sum = sum(Count))

#homeless_per_state <- filter(total_homeless, State =="CA") 
state_save_csv <- function(state_name) {
  output_data <- paste("Data/Data_by_states/", state_name, ".csv", sep = "")
  state_of_data <- filter(total_homeless, State == state_name)
  final_output <- write.csv(state_of_data, output_data, row.names = FALSE)
  return(final_output)
}
lapply(total_homeless$State,state_save_csv)

                      

# server <- function(input, output) {
#   output$country_wide_graph <- renderPlotly({
#   library(plotly)
#   df$hover <- with(df, paste(State, '<br>', "County", CoC Name,"<br>",
#                              "Count", Count))
#   # give state boundaries a white border
#   l <- list(color = toRGB("White"), width = 2)
#   # specify some map projection/options
#   g <- list(
#     scope = 'usa',
#     projection = list(type = 'albers usa'),
#     showlakes = TRUE,
#     lakecolor = toRGB('blue')
#   )
# 
#   p <- plot_geo(df, locationmode = 'USA-states') %>%
#     add_trace(
#       z = ~Count, text = ~hover, locations = ~State,
#       color = ~Count, colors = 'Purples'
#     ) %>%
#     colorbar(title = "Population") %>%
#     layout(
#       title = 'Distribution of Homeless Populaiton Around the United States<br>(Hover for breakdown)',
#       geo = g
#     )
# })
#   }
