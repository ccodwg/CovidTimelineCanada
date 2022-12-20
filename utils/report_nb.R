# Update New Brunswick weekly report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# make sure tabulizer is installed
# install.packages("rJava") # https://datawookie.dev/blog/2018/02/installing-rjava-on-ubuntu/
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))

# load pipe
library(magrittr)

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- as.Date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# get URL of today's report
url <- rvest::read_html("https://www2.gnb.ca/content/gnb/en/corporate/promo/covid-19/COVIDWATCH.html") %>%
  rvest::html_elements("a") %>%
  {paste0("https://www2.gnb.ca", rvest::html_attr(.[grep("Full Report", rvest::html_text2(.))][1], "href"))}

# extract text and tables from relevant pages
text <- tabulizer::extract_text(url, pages = 1)
tabs <- tabulizer::extract_tables(url, pages = c(7, 10))

# extract week and generate date_start and date_end
epi_week <- readr::parse_number(gsub(" ", "", stringr::str_extract(text, "\\( W E E K.*\\)")))
date_start <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week)
date_end <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week) + 6

# construct output table
out <- dplyr::tibble(
  date = date_local,
  source = url,
  date_start = date_start,
  date_end = date_end,
  region = "NB",
  sub_region_1 = c("", paste0("Zone ", 1:7)),
  cases = NA, # calculated by formula
  cases_weekly = NA,
  `cumulative_cases_since_2022-08-28` = NA,
  `cumulative_cases_since_2022-08-28_weekly_diff` = NA, # calculated by formula
  deaths = NA, # calculated by formula
  deaths_weekly = NA,
  `cumulative_deaths_since_2022-08-28` = NA,
  `cumulative_deaths_since_2022-08-28_weekly_diff` = NA, # calculated by formula
  new_hospitalizations = NA, # calculated by formula
  new_hospitalizations_weekly = NA,
  `cumulative_new_hospitalizations_since_2022-08-28` = NA,
  `cumulative_new_hospitalizations_since_2022-08-28_weekly_diff` = NA, # calculated by formula
  new_icu = NA,
  new_icu_weekly = NA,
  `cumulative_new_icu_since_2022-08-28` = NA,
  `cumulative_new_icu_since_2022-08-28_weekly_diff` = NA, # calculated by formula
  tests_completed = NA,
  tests_completed_weekly = NA, # calculated by formula
  `cumulative_tests_completed_since_2022-08-28` = NA,
  `cumulative_tests_completed_since_2022-08-28_weekly_diff` = NA # calculated by formula
)

# add provincial data
out[1, "cases_weekly"] <- readr::parse_number(tabs[[1]][6, 1])
out[1, "cumulative_cases_since_2022-08-28"] <- readr::parse_number(stringr::str_extract(tabs[[1]][6, 1], "(\\d+)(?!.*\\d)")) # extract last number
out[1, "deaths_weekly"] <- readr::parse_number(tabs[[1]][9, 1])
out[1, "cumulative_deaths_since_2022-08-28"] <- readr::parse_number(stringr::str_extract(tabs[[1]][9, 1], "(\\d+)(?!.*\\d)")) # extract last number
out[1, "new_hospitalizations_weekly"] <- readr::parse_number(tabs[[1]][7, 1]) # extract first number
out[1, "cumulative_new_hospitalizations_since_2022-08-28"] <- readr::parse_number(stringr::str_extract(tabs[[1]][7, 1], "(\\d+)(?!.*\\d)")) # extract last number
out[1, "new_icu_weekly"] <- readr::parse_number(tabs[[1]][8, 1]) # extract first number
out[1, "cumulative_new_icu_since_2022-08-28"] <- readr::parse_number(stringr::str_extract(tabs[[1]][8, 1], "(\\d+)(?!.*\\d)")) # extract last number
out[1, "tests_completed_weekly"] <- readr::parse_number(tabs[[1]][5, 1]) # extract first number
out[1, "cumulative_tests_completed_since_2022-08-28"] <- readr::parse_number(stringr::str_extract(tabs[[1]][5, 1], "(\\d+)(?!.*\\d)")) # extract last number

# add health region data
out[2:8, "cases_weekly"] <- readr::parse_number(tabs[[2]][2:8, 2])
out[2:8, "new_hospitalizations_weekly"] <- readr::parse_number(tabs[[2]][2:8, 3])
out[2:8, "new_icu_weekly"] <- readr::parse_number(tabs[[2]][2:8, 4])
out[2:8, "tests_completed_weekly"] <- readr::parse_number(stringr::str_extract(tabs[[2]][2:8, 1], "(\\d+)(?!.*\\d)")) # extract last number

# check column sums
out[["cases_weekly"]][1] == sum(out[["cases_weekly"]][2:8])
out[["new_hospitalizations_weekly"]][1] == sum(out[["new_hospitalizations_weekly"]][2:8])
out[["new_icu_weekly"]][1] == sum(out[["new_icu_weekly"]][2:8])
out[["tests_completed_weekly"]][1] == sum(out[["tests_completed_weekly"]][2:8])

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "nb_weekly_report_2")
