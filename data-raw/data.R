## code to prepare `my_dataset` dataset goes here

load("./data-raw/data_long.RData")

data <- df_univariate %>%
  dplyr::mutate(timestamp = CET,
                timeseries = Power_total) %>%
  dplyr::select(timestamp, timeseries)
  
data <- xts::xts(data$timeseries, order.by = data$timestamp, tzone = "Europe/Rome")

usethis::use_data(data, overwrite = TRUE)
