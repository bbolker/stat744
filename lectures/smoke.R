library(readr)
library(dplyr)

smoke <- read_csv(input_files[[1]]) %>% rename(smoking=smoke)
