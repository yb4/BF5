#Setting up libraries required for this task
library(shiny)
library(dplyr)
library(data.table)
library(ggplot2)
library(R.utils)
library(ggvis)
install.packages('openintro')
library(openintro)
library(ggrepel)
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
                          filter(state != "National") 
drunk_people_per_state <- drunk_people_per_state %>% mutate(state, State = state2abbr(state)) %>% mutate(State = tolower(State)) %>% 
                          select(State, average)

homeless_and_drunk_people <- left_join(homeless_people_per_state,drunk_people_per_state)
#names(drunk_people_per_state) <- c("region", "average")
names(drunk_people_per_state) <- c("State", "average")
names(homeless_people_per_state) <- c("State", "Count")

scatter_homeless_and_drunk <- ggplot(homeless_and_drunk_people, aes(x=average, y=Count,color = State, label=State)) + 
                            geom_point(shape = "diamond", size = 1) + theme_minimal() 
scatter_homeless_and_drunk <- scatter_homeless_and_drunk + geom_label_repel(aes(label=State),
                                                                       box.padding = 0.35,
                                                                      point.padding = 0.5,
                                                                      segment.color = 'grey50') + theme_classic() + labs(x = "Average Drinking",
                                                                      y = "Count of Homeless", title = "Value of Binge Drinking for Each State for 2012") 
#scatter_homeless_and_drunk <- scatter_homeless_and_drunk + theme(axis.text.x = element_blank())

plott <- ggplot (drunk_people_per_state, aes(x=State, y=average), color = "class") + geom_bar(stat = "identity")
          + ggplot(homeless_people_per_state, aes(x=drunk_people_per_state$state.abb)) 

# Following is the code for a GG Vis Plot for Drunk Peopel and HomeLess People
# plott <- homeless_people_per_state %>% ggvis(~State, ~Count) %>% layer_points(fill = ~temp_name) #%>% drunk_people_per_state %>% ggvis(~region, ~average) %>% layer_lines()
# plott <- drunk_people_per_state %>% ggvis(~State, ~average) %>% layer_paths()

names(drunk_people_per_state) <- c("State", "Average")
states <- map_data("state")
graph_drunk <- ggplot(states) + geom_map(data = states, map = states,
                                   aes(x = long, y = lat, map_id = region),
                                   fill = "grey", color = "white", size = 0.15)
graph_drunk <- graph_drunk + geom_map(data = drunk_people_per_state, map = states, aes(fill = Average, map_id = State))

# Clean up data for homeless people in States
state_save_csv <- function(state_name) {
  output_data <- paste("Data/Data_by_states/", state_name, ".csv", sep = "")
  state_of_data <- filter(total_homeless, State == state_name)
  final_output <- write.csv(state_of_data, output_data, row.names = FALSE)
  return(final_output)
}
lapply(total_homeless$State,state_save_csv)
