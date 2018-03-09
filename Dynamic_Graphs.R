##########################################################
##------------------- GGvis -------------------------#####
library(tidyverse)
library(ggvis)

mtcars %>% ggvis(~mpg, ~disp, stroke = ~vs) %>% layer_points()
mtcars %>% ggvis(~mpg, ~disp, fill = ~vs) %>% layer_points()
mtcars %>% ggvis(~mpg, ~disp, size = ~wt) %>% layer_points()
mtcars %>% ggvis(~mpg, ~disp, shape = ~factor(cyl)) %>% layer_points()
mtcars %>% ggvis(~mpg, ~disp, fill := "red", stroke := "black") %>% layer_points()
mtcars %>% ggvis(~mpg, ~disp, size := 300, opacity := 0.4) %>% layer_points()

##Interaction
# Slider for size and opacity
mtcars %>% 
  ggvis(~wt, ~mpg, 
        size := input_slider(10, 100),
        opacity := input_slider(0, 1)
  ) %>% 
  layer_points()
# Slider for histogram width and center
mtcars %>% 
  ggvis(~wt) %>% 
  layer_histograms(width =  input_slider(0, 2, step = 0.10, label = "width"),
                   center = input_slider(0, 2, step = 0.05, label = "center"),
                   fill:="grey")

# Checkbox
model_type <- input_checkbox(label = "Use flexible curve",
                             map = function(val) if(val) "loess" else "lm")
mtcars %>% ggvis(~wt, ~mpg) %>%
  layer_model_predictions(model = model_type)%>%
  add_axis("x", title = "Weight") %>%
  add_axis("y", title = "Miles per gallon")


# Show info (identification or labeling)

mtcars %>% ggvis(~wt, ~mpg, size := 300, key:=~id) %>% 
  layer_points() %>% 
  add_tooltip(function(data){paste0("Weight: ", data$wt)},"hover")

install.packages("shiny")
library(shiny)
mtcars$id <- 1:nrow(mtcars)
all_values <- function(x) {
  if(is.null(x)) return(NULL)
  row <- mtcars[mtcars$id == x$id, ]
  paste0(names(row), ": ", format(row), collapse = "<br />")
}
mtcars %>% ggvis(x = ~wt, y = ~mpg, key := ~id) %>%
  layer_points() %>%
  add_tooltip(all_values, "hover")

hp <- function(x) {
  if(is.null(x)) return(NULL)
  row <- mtcars$hp[mtcars$id == x$id]
  paste0("Horsepower: ", row)
}
mtcars %>% ggvis(x = ~wt, y = ~mpg, key := ~id) %>%
  layer_points() %>%
  add_tooltip(hp, "hover")

mtcars %>% ggvis(~wt, ~mpg, size := 300, key:=~id) %>% 
  layer_points() %>% 
  add_tooltip(function(data){paste0("Cylinder: ", mtcars$cyl[mtcars$id == data$id])},"hover")


##########################################################
##------------------- ggplotly -------------------------##

## read data
dat1<-(read_csv("stock_price.csv")
       %>% select(c(Company,Date,Close,Volume)))
View(dat1)

gg1<-(ggplot(dat1,aes(x=Date,y=Close,colour=Company))+
        geom_line()
)
ggp1<-ggplotly(gg1)
ggp1


##########################################################
##------------------- plot_ly -------------------------##
library(tidyverse)
library(plotly)
dat1<-(read_csv("stock_price.csv")
       %>% select(c(Company,Date,Close,Volume)))
View(dat1)

pp0 <- plot_ly(
  dat1, x = ~Date, y = ~Close, color = ~Company, type="scatter", mode='lines',
  # Hover text:
  text = ~paste('Price:', Close, '<br> Volume: ', Volume), hoverinfo="text+x")
pp0
#Trace type could be one of the following: 
# 'scatter', 'box', 'bar', 'heatmap', 'histogram', 'histogram2d', 'histogram2dcontour', 'pie', 
# 'contour', 'scatterternary', 'sankey', 'scatter3d', 'surface', 'mesh3d', 'scattergeo', 'choropleth', 
# 'scattergl', 'pointcloud', 'heatmapgl', 'parcoords', 'scattermapbox', 'carpet', 'scattercarpet', 
# 'contourcarpet', 'ohlc', 'candlestick', 'area'
dat2 <- ((read_csv("stock_price.csv")
          %>% select(c(Company,Date,Close)))
         %>% spread(key=Company,value=Close) 
)
View(dat2)
pp1 <- plot_ly(data = dat2, x = ~Date)%>%
  add_trace(y = ~Boeing, name = 'Boeing',type="scatter",mode = 'lines') %>%
  add_trace(y = ~CocaCola, name = 'Coca Cola', type="bar") %>%
  add_trace(y = ~GoldmanSachs, name = 'Goldman Sachs', type="scatter", mode = 'lines+markers')%>%
  add_trace(y = ~ProcterGamble, name = 'P&G', type="scatter", mode = 'markers')
pp1

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
xname <- list(
  zeroline=FALSE,
  title = "Date",
  titlefont = f
)
yname <- list(
  zeroline=TRUE,
  title = "Closing Price",
  titlefont = f
)
pp2 <- pp1%>%
  layout(xaxis = xname, yaxis = yname, title="Stock Price")
pp2



##########################################################
##-------------------highcharter------------------------##
# Highcharter is a R wrapper for highcharts, a commercial JavaScript charting library
# https://www.rdocumentation.org/packages/highcharter/versions/0.5.0
# http://jkunst.com/highcharter/
library(magrittr)
library(highcharter)

# Example 1
# hchart
hchart(mpg, "scatter", hcaes(x = displ, y = hwy, group = class))%>%
  hc_tooltip(pointFormat = "Engine displacement: {point.x} <br> Highway miles per gallon: {point.y} <br> Manufacturer: {point.manufacturer}")

hchart(diamonds$cut, colorByPoint = TRUE, name = "Cut")%>% 
  hc_title(text = "discrete")
hchart(diamonds$price, color = "#B71C1C", name = "Price") %>% 
  hc_title(text = "Continuous")

# Example 2
# highchart
highchart() %>%  
  hc_series(
    list(
      name = "Tokyo",
      data = c(7.0, 6.9, 9.5, 14.5, 18.4, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6)
    ),
    list(
      name = "London",
      data = c(3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8)
    )
  )

highchart() %>% 
  hc_chart(type = "column") %>% 
  hc_title(text = "A highcharter chart") %>% 
  hc_xAxis(categories = 2012:2016) %>% 
  hc_add_series(data = c(3900,  4200,  5700,  8500, 11900),
                name = "Downloads")

# stock price 
library(quantmod)
x <- getSymbols("GOOG", auto.assign = FALSE)
y <- getSymbols("AMZN", auto.assign = FALSE)
highchart(type = "stock") %>% 
  hc_add_series(x) %>% 
  hc_add_series(y)


##########################################################
##------------------- crosstalk ------------------------##
#When you have two plots of the same data and you want to be able to 
#link the data from one plot to the data in the other plot, you can use the crosstalk package.

library(crosstalk)
# Define a shared data object
shared <-SharedData$new(mtcars)
# Make a boxplot of disp
box1<-plot_ly(shared, y = ~disp) %>% 
  add_boxplot(name = "Overall",color=I("navy"))
# Make a scatterplot of mpg vs disp
scatter1 <- plot_ly(shared, x = ~mpg, y = ~disp) %>%
  add_markers(color=I("navy"))
# Define two subplots: boxplot and scatterplot
subplot(box1, scatter1, shareY = TRUE, titleX = T) %>% 
  layout(dragmode = "select")


##########################################################
##---------------------GoogleVis------------------------##
#https://cran.r-project.org/web/packages/googleVis/vignettes/googleVis.pdf
library(googleVis)
# Example 1: Bar chart and Column chart
winter.olympics <- data.frame(country=c("Norway","Canada","China"),
              Gold=c(14,11,1),
              Silver=c(14,8,6),
              Bronze=c(11,10,2)
)
bar1 <- gvisBarChart(winter.olympics)
plot(bar1)
column1 <- gvisColumnChart(winter.olympics)
plot(column1)

#Example 2: Motion Chart
#idvar: column name of data with the subject to be analysed
View(Fruits)
motion1 <- gvisMotionChart(Fruits, 
                       idvar="Fruit", 
                       timevar="Year",
                       xvar="Sales",
                       yvar="Expenses",
                       sizevar = "Profit",
                       colorvar = "Location",
                       options=list(colors="['#fff000', '#123456','#cbb69d']"))
plot(motion1)


#Example 3: Motion Chart
motion2 <- gvisMotionChart(dat1,idvar="Company",timevar="Date")
plot(motion2)


##Assignment##
#For our friends in class, please create an interactive plot or more to highlight 
#at least 2 different types of interactions that we introduced in class using any packages!




