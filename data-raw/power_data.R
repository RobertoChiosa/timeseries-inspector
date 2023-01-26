## code to prepare `my_dataset` dataset goes here

load("./data-raw/data_small.RData")

library(dplyr)
power_data <- df_univariate %>%
  dplyr::mutate(timestamp = CET,
                timeseries = Power_total) %>%
  dplyr::select(timestamp, timeseries)
  
power_data <- xts::xts(power_data$timeseries, order.by = power_data$timestamp, tzone = "Europe/Rome")

usethis::use_data(power_data,overwrite = TRUE,internal = FALSE)
