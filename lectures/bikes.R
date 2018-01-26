library(readr)
library(dplyr)

bike_weather <- read_csv(input_files[[2]])

bikes <- (read_csv(input_files[[1]])
	%>% left_join(bike_weather)
	%>% rename(rentals=cnt)
   %>% mutate(weather=reorder(weather,weathersit))
)

print(table(bikes$rentals))

# rdsave(bikes)
