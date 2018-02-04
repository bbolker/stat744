library(dplyr)
library(readr)

dat <- (read_csv(input_files[[1]])
	%>% mutate(cases = ifelse(cases>0, cases, NA))
)

vacc <- (dat
	%>% filter (vaccine != "FALSE")
)

# rdsave(dat, vacc)

