library(dplyr)

offset <- 15
temps <- (read.csv(input_files[[1]])
	%>% mutate(Temp=offset+Mean)
)

gis <- (temps
	%>% filter(Source=="GISTEMP")
	%>% select(-Source)
)

# rdsave(temps, gis)
