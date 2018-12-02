#Setting up libraries required for this task
library(shiny)
library(dplyr)
library(data.table)
library(ggplot2)
library(R.utils)

homeless_by_state <- data.table :: fread("data/Homelessness.csv", sep = ",", stringsAsFactors = FALSE)
total_homeless <- homeless_by_state %>% filter(Measures == "Total Homeless")
write.csv(total_homeless, "data/total_homeless.csv", row.names = TRUE)

# Help needed here, trying to calculate the sum total of the Homeless Population
# gives me the nrow() instead
sum_total_homeless <- sum(total_homeless, sum = sum(Count))



server <- function(input, output) {
  output$hm_per_state <- renderPlot({
    
  })
}
