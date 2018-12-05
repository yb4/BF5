library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)
library(geojsonio)
library(ggplot2)

shinyServer(function(input, output) {
  
  
  # load homeless data
  df_homeless <- read.csv("Data/Homelessness.csv", stringsAsFactors = FALSE)
  
  # clean up homeless data
  state_name <- append(state.name, "District of Columbia", after = 8) 
  state_abb <- append(state.abb, "DC", after = 8)
  df_homeless['State'] <- state_name[match(df_homeless$State, state_abb)]
  df_homeless$Count[is.na(df_homeless$Count)] <- 0
  df_homeless$Count <- as.numeric(sub(",", "", df_homeless$Count, fixed = TRUE))
  df_homeless$Year <- dmy(df_homeless$Year)
  df_homeless <- na.omit(df_homeless)
  
  geo_homeless <- geojson_read( x = "Data/us-states.json"
                                , what = "sp", stringsAsFactor = FALSE)
  
  # rendering bar graph--------------------------------------------------------------------
  output$by_state <- renderPlot({
    #filter year and sum total homeless
    df_homeless$Year <- year(df_homeless$Year)
    df_homeless <- filter(df_homeless, Measures == input$state_indicator, State == input$state) %>% group_by(Year) %>%
      summarise("total" = sum(Count))
    
    bar <- ggplot(df_homeless, aes(x=Year, y=total)) + 
      geom_bar(stat="identity", fill=c("green")) + 
      geom_label(aes(label=total), size = 3) +
      labs(y = "Homeless Population") + 
      ggtitle(paste0(input$state,"'s", input$state_indicator, " Population by Year")) +
      scale_x_discrete(name = 'Year', limits = 2007:2016)
    
    bar
  })
  
  # render ranking table -------------------------------------------------------------------
  output$ranking <- renderTable({
    # filter year and sum
    df_homeless <- filter(df_homeless, year(Year) == input$rank_year)
    df_homeless <- filter(df_homeless, Measures == input$rank_indicator) %>% group_by(State) %>% 
      summarise("Total" = sum(Count))
    
    # join with population by state
    df_pop <- read.csv("Data/acs2015_census_tract_data.csv", stringsAsFactors = FALSE)
    df_pop <- df_pop %>% group_by(State) %>% summarise("Population" = sum(TotalPop))
    df_homeless <- left_join(df_homeless, df_pop, by = "State")
    
    # mutate proportion column
    df_homeless <- mutate(df_homeless, Percentage = (Total / Population) * 100 ) %>% arrange(-Percentage)
    
    #Final cleanup and add ranked index
    df_homeless$Total <- format(df_homeless$Total, nsmall = 0)
    colnames(df_homeless)[2] <- "Total Homeless"
    df_homeless$Rank <- 1:51
    df_homeless <- select(df_homeless, Rank, State, "Total Homeless", Population, Percentage)
    
  })
  
  # render homeless map ---------------------------------------------------------------------
  output$homeless_m <- renderLeaflet({
    
    # filter year and sum
    df_homeless <- filter(df_homeless, year(Year) == input$year)
    df_homeless <- filter(df_homeless, Measures == input$indicator) %>% group_by(State) %>% 
      summarise("total" = sum(Count))
    
    # join with population by state
    df_pop <- read.csv("Data/acs2015_census_tract_data.csv", stringsAsFactors = FALSE)
    df_pop <- df_pop %>% group_by(State) %>% summarise("population" = sum(TotalPop))
    df_homeless <- left_join(df_homeless, df_pop, by = "State")
    
    # mutate proportion column
    df_homeless <- mutate(df_homeless, percentage = (total / population) * 100 )
    
    # cleanup before joining sp
    
    colnames(df_homeless)[1] <- "name"
    df_homeless[c(2,3,4)] <- sapply(df_homeless[c(2,3,4)],as.double)
    
    # import and join us-state geo sp
    
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
    
    bins <- seq(0, 0.5, by= 0.05)
    f_palet = colorBin("YlOrRd", domain = geo_homeless@data$percentage, bins = bins)
    
    #Set label and highight options
    l_hl_options = highlightOptions(weight = 5, color = "#666", dashArray = "",
                                    fillOpacity = 0.4, bringToFront = TRUE)
    
    l_lb_options = labelOptions(style = list("font-weight" = "normal"), 
                                textsize = "12px")
    
    #create map
    m = leaflet(geo_homeless, width = "60%") %>% 
      addTiles() %>% 
      addPolygons(fillColor = ~f_palet(percentage), weight = 2, opacity = 1,color = "white",dashArray = "3",  
                  fillOpacity = 0.4, highlight = l_hl_options, label = v_lab, labelOptions = l_lb_options) %>% 
      addLegend(position = "bottomright", pal = f_palet, values = geo_homeless@data$percentage, 
                title = "Homelessness Percentage")
    
    m
  })
  
})
