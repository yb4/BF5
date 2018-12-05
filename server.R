#Setting up libraries required for this task
library(shiny)
library(dplyr)
library(data.table)
library(ggplot2)
library(R.utils)
library(ggvis)
setwd("~/Desktop/BF5/")

homeless_by_state <- data.table :: fread("data/Homelessness.csv", sep = ",", stringsAsFactors = FALSE)
total_homeless <- homeless_by_state %>% filter(Measures == "Total Homeless") %>% filter(Year == "1/1/2012") 
write.csv(total_homeless, "data/total_homeless.csv", row.names = TRUE)

#Clean up data for Binge Drinking in States
drunkards_by_state <- data.table :: fread ("data/binge_drinking.csv", sep = ",", stringsAsFactors = FALSE)
total_drunkards <- drunkards_by_state %>% select(state, location, both_sexes_2012)
total_drunkards
state_drink_csv <- function(state_name) {
  output_data <- paste("Data/Data_by_states/", state_name, "d.csv", sep = "")
  state_of_data <- filter(total_drunkards, state == state_name)
  final_output <- write.csv(state_of_data, output_data)
  return(final_output)
}
lapply(total_drunkards$state,state_drink_csv)

homeless_by_state$Count <- as.numeric(gsub(",","",homeless_by_state$Count))
homeless_people_per_state <- homeless_by_state%>% filter(Year == "1/1/2012") %>% 
                            select(State, Count) %>% filter(State != "GU" & State != "PR" & State != "VI") %>% 
                                filter(Count != "NA") %>%  group_by(State) %>% 
                          summarise(Count = sum(as.numeric(Count))) %>% mutate(State = tolower(State))

# names(homeless_people_per_state) <- c("region", "average")
# states <- map_data("state")
# graph <- ggplot(states) + geom_map(data = states, map = states,
#                                    aes(x = long, y = lat, map_id = region),
#                                    fill = "#ffffff", color = "#ffffff", size = 0.15)
# graph <- graph + geom_map(data = homeless_people_per_state, map = states, aes(fill = average, map_id = region))


drunk_people_total_by_state <- data.table :: fread ("data/binge_drinking.csv", sep = ",", stringsAsFactors = FALSE)
drunk_people_per_state <- drunk_people_total_by_state %>% select(state, both_sexes_2012) %>% 
                           group_by(state) %>% summarise(average = mean(both_sexes_2012)) %>% 
                          filter(state != "National") %>% mutate(state = tolower(state))

#names(drunk_people_per_state) <- c("region", "average")
names(drunk_people_per_state) <- c("State", "average")
names(homeless_people_per_state) <- c("State", "Count")

lapply(drunk_people_per_state, state.abb[grep(State, state.name)])

plott <- ggplot (drunk_people_per_state, aes(x=State, y=average), color = "class") + geom_bar(stat = "identity")
          + ggplot(homeless_people_per_state, aes(x=drunk_people_per_state$state.abb))

# Following is the code for a GG Vis Plot for Drunk Peopel and HomeLess People
# plott <- homeless_people_per_state %>% ggvis(~State, ~Count) %>% layer_points(fill = ~temp_name) #%>% drunk_people_per_state %>% ggvis(~region, ~average) %>% layer_lines()
# plott <- drunk_people_per_state %>% ggvis(~State, ~average) %>% layer_paths()

names(drunk_people_per_state) <- c("region", "average")
states <- map_data("state")
graph <- ggplot(states) + geom_map(data = states, map = states,
                                   aes(x = long, y = lat, map_id = region),
                                   fill = "#ffffff", color = "#ffffff", size = 0.15)
graph <- graph + geom_map(data = drunk_people_per_state, map = states, aes(fill = average, map_id = region))

                          


# Clean up data for homeless people in States
state_save_csv <- function(state_name) {
  output_data <- paste("Data/Data_by_states/", state_name, ".csv", sep = "")
  state_of_data <- filter(total_homeless, State == state_name)
  final_output <- write.csv(state_of_data, output_data, row.names = FALSE)
  return(final_output)
}
lapply(total_homeless$State,state_save_csv)



#data_sets <- read.csv("data/data_by_states/ME.csv", stringsAsFactors = FALSE)
data_sets

data_sets_drunk <- read.csv("data/data_by_states/MainedrunkPeople.csv", stringsAsFactors = FALSE)
#data_sets_drunk %>% ggvis(~location, ~both_sexes_2012) %>% layer_lines()





my_server <- function(input, output) {
  output$states <- renderPlot ({
    input_state <- input$state_select
    data_sets <- read.csv(paste("Data/Data_by_states/", input_state, "d.csv", sep = ""), stringsAsFactors = FALSE)
    #stata_drunk_data_select <- read.csv(paste("data/data_by_states/", input_state,"drunkPeople.csv", sep=""), stringsAsFactors = FALSE)
    ggplot(
      data_sets,
      aes(x=location,y=both_sexes_2012) +
      labs(xlab = input_state, ylab = "Number of Homeless Reported in the Year 2012") 
    )
    #data_sets %>% ggvis(~Year, ~Count) %>% layer_points(fill = ~temp_name) #%>% data_sets_drunk %>% ggvis(~location, ~both_sexes_2012) %>% layer_lines()
    })
}

