library(rgdal) ##allows you to use readOGR

library(sf)
library(dplyr)
ss <- st_read("shapefiles/cb_2016_us_state_20m.shp", quiet = TRUE)
sc <- ss %>% st_centroid() %>% st_coordinates() %>% as.data.frame 
ss$X <- sc$X
ss$Y <- sc$Y

## ?
## https://github.com/r-spatial/sf/issues/231
sfc_as_cols <- function(x, names = c("x","y")) {
  stopifnot(inherits(x,"sf") && inherits(sf::st_geometry(x),"sfc_POINT"))
  ret <- sf::st_coordinates(x)
  ret <- tibble::as_tibble(ret)
  stopifnot(length(names) == ncol(ret))
  x <- x[ , !names(x) %in% names]
  ret <- setNames(ret,names)
  dplyr::bind_cols(x,ret)
}

library(ggplot2)
ggplot(ss) +
    geom_text(aes(X,Y,label=NAME))


ss <- st_read("shapefiles/ZIP_CODE_040114.shp", quiet = TRUE)
library(leaflet)
ggplot(ss)+geom_line()

m <- leaflet(ss) %>%   addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(color = "#444444", weight = 2, smoothFactor = 0.5,
                opacity = 0.1, fillOpacity = 0.8,
                fillColor = ~colorQuantile("YlOrRd", POPULATION)(POPULATION),
                highlightOptions = highlightOptions(color = "white", weight = 2,
                                                    bringToFront = TRUE))
addTiles()
ss %>% leaflet() %>% addPolygons() %>%
      addProviderTiles("CartoDB.Positron")

leaflet(data = ss) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  setView(40.6666, -74, zoom = 13) %>% 
  addPolygons(fillOpacity = 0.7,
    fillColor = ~pal(count), color = "darkgrey", weight = 2)



sh <- sf::st_read("shapefiles/ZIP_CODE_040114.shp")
plot(sh,max.plot=12)
