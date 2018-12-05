library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)
library(geojsonio)

shinyServer(function(input, output) {
  # load homeless data
  df_homeless <- read.csv("~/Desktop/201/BF5/Data/Homelessness.csv", stringsAsFactors = FALSE)

#Setting up libraries required for this task @yashb4
library(ggplot2)
library(ggvis)
library(openintro)
library(ggrepel)
library(jsonlite)

shinyServer(function(input, output) {
  #Load homeless data
  df_homeless <- read.csv("~/Desktop/BF5/Data/Homelessness.csv", stringsAsFactors = FALSE)
  
  # clean up homeless data
  state_name <- append(state.name, "District of Columbia", after = 8) 
  state_abb <- append(state.abb, "DC", after = 8)
  df_homeless['State'] <- state_name[match(df_homeless$State, state_abb)]
  df_homeless$Count[is.na(df_homeless$Count)] <- 0
  df_homeless$Count <- as.numeric(sub(",", "", df_homeless$Count, fixed = TRUE))
  df_homeless$Year <- dmy(df_homeless$Year)
  df_homeless <- na.omit(df_homeless)
  
  #Clean up Homeless Data, this time for 2012
  #One of the few years we have intersecting Data between Drinking and Homeless 
  #numbers reported is 2012, and thus we have chosen 2012 for this task
  homeless_by_state <- data.table :: fread("data/Homelessness.csv", sep = ",", stringsAsFactors = FALSE)
  total_homeless <- homeless_by_state %>% filter(Measures == "Total Homeless") %>% filter(Year == "1/1/2012") 
  write.csv(total_homeless, "data/total_homeless.csv", row.names = TRUE)
  
  # Extracting Total Number of Homeless People per state form 2012 data, leaving Guam and 
  # Puerto Rico asise which have also been included in the dataset
  homeless_by_state$Count <- as.numeric(gsub(",","",homeless_by_state$Count))
  homeless_people_per_state <- homeless_by_state%>% filter(Year == "1/1/2012") %>% 
                              select(State, Count) %>% filter(State != "GU" & State != "PR" & State != "VI") %>% 
                              filter(Count != "NA") %>%  group_by(State) %>% 
                             summarise(Count = sum(as.numeric(Count))) %>% mutate(State = tolower(State))
  
  #Extracting and cleaning data for Drunk People per state for 2012 
  drunk_people_total_by_state <- data.table :: fread ("data/binge_drinking.csv", sep = ",", stringsAsFactors = FALSE)
  drunk_people_per_state <- drunk_people_total_by_state %>% select(state, both_sexes_2012) %>% 
                            group_by(state) %>% summarise(average = mean(both_sexes_2012)) %>% 
                            filter(state != "National") 
  drunk_people_per_state <- drunk_people_per_state %>% mutate(state, State = state2abbr(state)) %>% 
                            mutate(State = tolower(State)) %>%  select(State, average)
  
  #Making a common dataset for Homeless Values and Drinking Values Extraceted
  #This gives us the ease of making interactive plots with just one dataset
  homeless_and_drunk_people <- left_join(homeless_people_per_state,drunk_people_per_state)
  
  
  
  # render homeless map ---------------------------------------------------------------------
  output$homeless_m <- renderLeaflet({
    
  # filter year and sum
  df_homeless <- filter(df_homeless, year(Year) == 2016)
  df_homeless <- filter(df_homeless, Measures == input$indicator) %>% group_by(State) %>% 
    summarise("total" = sum(Count))

  # join with population by state
  df_pop <- read.csv("~/Desktop/BF5/Data/acs2015_census_tract_data.csv", stringsAsFactors = FALSE)
  df_pop <- df_pop %>% group_by(State) %>% summarise("population" = sum(TotalPop))
  df_homeless <- left_join(df_homeless, df_pop, by = "State")
    
  # mutate proportion column
  df_homeless <- mutate(df_homeless, percentage = (total / population) * 100 )
    
  # cleanup before joining sp
    
  colnames(df_homeless)[1] <- "name"
  df_homeless[c(2,3,4)] <- sapply(df_homeless[c(2,3,4)],as.double)
    
  # import and join us-state geo sp
  geo_homeless <- 
      geojson_read( x = "~/Desktop/201/BF5/Data/us-states.json"
                    , what = "sp", stringsAsFactor = FALSE)
    
    geojson_read( x = "~/Desktop/BF5/Data/us-states.json", what = "sp", stringsAsFactor = FALSE)

  geo_homeless@data <- right_join(geo_homeless@data, df_homeless, by = 'name')
    
  #set label
  v_lab = sprintf(stringr::str_c("<strong>State:</strong> %s<br>",
                                  "<strong>Total Population:</strong> %s<br>",
                                  "<strong>Homeless Population: </strong> %s <br>",
                                  "<strong>Homeless Percentage: </strong> %.2f%%",
                                  collapse = ""),
                  geo_homeless@data$name, geo_homeless@data$population, geo_homeless@data$total,
                  geo_homeless@data$percentage) 
    
  v_lab = purrr::map(v_lab, htmltools::HTML)
    
  #set color palet 
  f_palet = colorQuantile("RdYlBu", domain = geo_homeless@data$percentage, 
                            n = 10, reverse = TRUE)
    
  #Set label and highight options
  l_hl_options = highlightOptions(weight = 5, color = "#666", dashArray = "",
                                  fillOpacity = 0.4, bringToFront = TRUE)
    
  l_lb_options = labelOptions(style = list("font-weight" = "normal"), 
                                textsize = "12px")
    
  #create map
  m = leaflet(geo_homeless, width = "100%") %>% 
    addTiles() %>% 
    addPolygons(fillColor = ~f_palet(percentage), weight = 2, opacity = 1,color = "white",dashArray = "3",  
                fillOpacity = 0.4, highlight = l_hl_options, label = v_lab, labelOptions = l_lb_options) %>% 
    addLegend(position = "bottomright", pal = f_palet, values = geo_homeless@data$percentage, 
                title = "Homelessness Percentile")
  })

})

# Define server logic required to draw a histogram

   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  #Scatter Plot talking about Average Binge Drinking and Homeless Data Reported in Each State 
  output$homeless_drinking_plot <- renderPlot({
    names(drunk_people_per_state) <- c("State", "average")
    names(homeless_people_per_state) <- c("State", "Count")
    scatter_homeless_and_drunk <- ggplot(homeless_and_drunk_people, aes(x=average, y=Count,color = State, label=State)) + 
      geom_point(shape = "diamond", size = 1) + theme_minimal() 
    scatter_homeless_and_drunk <- scatter_homeless_and_drunk + geom_label_repel(aes(label=State),
                                    box.padding = 0.35,point.padding = 0.5,segment.color = 'grey50') + 
                                   theme_classic() + labs(x = "Average Drinking",
                                  y = "Count of Homeless",
                                  title = "Value of Binge Drinking vs Homeless Count for Each State for 2012") 
    output(scatter_homeless_and_drunk)
  })
  
  

  })

