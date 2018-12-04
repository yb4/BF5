library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)

#Load homeless data
df_homeless <- read.csv("~/Desktop/201/BF5/Data/Homelessness.csv", stringsAsFactors = FALSE)

#clean up homeless data
df_homeless['State'] <- state.name[match(df_homeless$State, state.abb)]
df_homeless$Count[is.na(df_homeless$Count)] <- 0
df_homeless$Count <- as.numeric(sub(",", "", df_homeless$Count, fixed = TRUE))
df_homeless$Year <- dmy(df_homeless$Year)
df_homeless[df_homeless$Count == 8350, 'State'] <- 'District of Columbia'
df_homeless <- na.omit(df_homeless)


# filter year and sum
df_homeless <- filter(df_homeless, year(Year) == 2016)
df_homeless <- filter(df_homeless, Measures == "Total Homeless") %>% group_by(State) %>% 
  summarise("Total_homeless" = sum(Count))


# join with population by state
df_pop <- read.csv("~/Desktop/201/BF5/Data/acs2015_census_tract_data.csv", stringsAsFactors = FALSE)
df_pop <- df_pop %>% group_by(State) %>% summarise("Total_pop" = sum(TotalPop))
df_homeless <- left_join(df_homeless, df_pop, by = "State")

# mutate proportion column
df_homeless <- mutate(df_homeless, Homeless_perc = (Total_homeless / Total_pop) * 100 )

# cleanup before joining sp
df_homeless <- rbind(df_homeless, data.frame('State' = 'Puerto Rico', 'Total_homeless' = 0, 
                                             'Total_pop' = 0, 'Homeless_perc' = 0))
colnames(df_homeless)[1] <- "name"
df_homeless[c(2,3,4)] <- sapply(df_homeless[c(2,3,4)],as.double)


m_geom1 <- 
  geojson_read( x = "https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json"
    , what = "sp", stringsAsFactors = FALSE)

m_geom1@data <- right_join(m_geom1@data, df_homeless, by = 'name')

v_lab = sprintf(stringr::str_c("<strong>State:</strong> %s<br>",
                                "<strong>Total Population:</strong> %s<br>",
                                "<strong>Homeless Population: </strong> %s",
                                collapse = ""),
                 m_geom1@data$name, m_geom1@data$Total_pop, m_geom1@data$Total_homeless) 
                # formatC(sp_rent@data$w_median, format = "f", digits = 0, big.mark = ","))

v_lab = purrr::map(v_lab, htmltools::HTML)

f_palet = colorQuantile("RdYlBu", domain = m_geom1@data$Homeless_perc, 
                       n = 10, reverse = TRUE)

l_hl_options = highlightOptions(weight = 5, color = "#666", dashArray = "",
                                fillOpacity = 0.4, bringToFront = TRUE)

l_lb_options = labelOptions(style = list("font-weight" = "normal"), 
                            textsize = "12px")

m1 = leaflet(m_geom1, width = "100%")
m1 = addTiles(m1)

m1 = addPolygons(m1,
                fillColor = ~f_palet(Homeless_perc),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.4,
                highlight = l_hl_options,
                label = v_lab,
                labelOptions = l_lb_options)

m1 = addLegend(m1, 
              position = "bottomright",
              pal = f_palet,
              values = m_geom1@data$Homeless_perc, 
              title = "Homelessness Percentile")




# My work ^

# load rent data ----------------------------------------------------------


#df_rent = readr::read_csv("~/Desktop/201/BF5/Data/kaggle_gross_rent.csv", col_types = l_cols)
df_rent = read.csv("Data/kaggle_gross_rent.csv", stringsAsFactors = FALSE)

# convert invalid UTF-8 characters that seem to be present ----------------
df_rent$County = iconv(df_rent$County, "UTF-8", "UTF-8", sub = "")

# load county geometry ----------------------------------------------------
m_geom = maps::map("county", fill = TRUE, plot = FALSE)

# build ID field in rent data to match geometry ---------------------------

df_rent = as.data.table(df_rent)

df_rent[, ID := sprintf("%s,%s", tolower(State_Name), 
                        tolower(stringr::str_trim(stringr::str_replace(County, "County", ""))))]

# calculate weighted median rent per county -------------------------------
df_rent = df_rent[Samples != 0, .(State_Name = State_Name[1],
                                  County = County[1],
                                  w_median = (1/sum(Samples))*sum(Samples*Median)),
                  by = "ID"]

# match rent and geometry data --------------------------------------------
df_rent = dplyr::left_join(tibble::tibble(ID = m_geom$names), df_rent, 
                           by = "ID")

# wrap in sp data structure -----------------------------------------------
sp_rent = sp::SpatialPolygonsDataFrame(maptools::map2SpatialPolygons(m_geom, IDs = m_geom$names),
                                       data = as.data.frame(df_rent), match.ID = "ID")

# build color palette for leaflet map -------------------------------------
f_pale = colorQuantile("RdYlBu", domain = sp_rent@data$w_median, 
                       n = 10, reverse = TRUE)

#next hting to do : fix f_pale to fix new data

# build labels ------------------------------------------------------------
v_labs = sprintf(stringr::str_c("<strong>County:</strong> %s<br>",
                                "<strong>State:</strong> %s<br>",
                                "<strong>Weighted median rent:</strong> $%s",
                                collapse = ""),
                 sp_rent@data$County, sp_rent@data$State_Name, 
                 formatC(sp_rent@data$w_median, format = "f", digits = 0, big.mark = ","))

v_labs = purrr::map(v_labs, htmltools::HTML)

# set options -------------------------------------------------------------


# build map ---------------------------------------------------------------
m = leaflet(sp_rent, width = "100%")
m = addTiles(m)

m = addPolygons(m,
                fillColor = ~f_pale(w_median),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.4,
                highlight = l_hl_options,
                label = v_labs,
                labelOptions = l_lb_options)

m = addLegend(m, 
              position = "bottomright",
              pal = f_pale,
              values = sp_rent@data$w_median, 
              title = "Rent percentile")

#m