library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)

#Load homeless data
df_homeless <- read.csv("~/Desktop/201/BF5/Data/Homelessness.csv", stringsAsFactors = FALSE)

#clean up homeless data
state_name <- append(as.list(state.name), "District of Columbia", after = 8) 
state_abb <- append(as.list(state.abb), "DC", after = 8)
df_homeless['State'] <- state_name[match(df_homeless$State, state_abb)]
df_homeless$Count[is.na(df_homeless$Count)] <- 0
df_homeless$Count <- as.numeric(sub(",", "", df_homeless$Count, fixed = TRUE))
df_homeless$Year <- dmy(df_homeless$Year)
df_homeless <- na.omit(df_homeless)


# filter year and sum
df_homeless <- filter(df_homeless, year(Year) == 2016)
df_homeless <- filter(df_homeless, Measures == "Total Homeless") %>% group_by(State) %>% 
  summarise("total" = sum(Count))


# join with population by state
df_pop <- read.csv("~/Desktop/201/BF5/Data/acs2015_census_tract_data.csv", stringsAsFactors = FALSE)
df_pop <- df_pop %>% group_by(State) %>% summarise("population" = sum(TotalPop))
df_homeless <- left_join(df_homeless, df_pop, by = "State")

# mutate proportion column
df_homeless <- mutate(df_homeless, percentage = (total / population) * 100 )

# cleanup before joining sp

colnames(df_homeless)[1] <- "name"
df_homeless[c(2,3,4)] <- sapply(df_homeless[c(2,3,4)],as.double)

# 
geo_homeless <- 
  geojson_read( x = "Data/us-states.json"
    , what = "sp", stringsAsFactor = FALSE)

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
m = leaflet(geo_homeless, width = "100%") %>% addTiles() %>% addPolygons(fillColor = ~f_palet(percentage),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.4,
                highlight = l_hl_options,
                label = v_lab,
                labelOptions = l_lb_options) %>%
addLegend(position = "bottomright",
              pal = f_palet,
              values = geo_homeless@data$percentage, 
              title = "Homelessness Percentile")