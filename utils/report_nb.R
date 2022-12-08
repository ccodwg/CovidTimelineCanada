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
tabs <- tabulizer::extract_tables(url, pages = c(2, 3))

# extract week and generate date_start and date_end
epi_week <- readr::parse_number(gsub(" ", "", stringr::str_extract(text, "\\( W E E K.*\\)")))
date_start <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week)
date_end <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week) + 6

# construct output table
out <- data.frame(
  date = date_local,
  source = url,
  date_start = date_start,
  date_end = date_end,
  region = "NB",
  sub_region_1 = c("", paste0("Zone ", 1:7)),
  cumulative_cases = NA,
  cases = NA,
  cumulative_deaths = NA,
  deaths = NA,
  cumulative_recovered = NA,
  active_cases = NA,
  active_hospitalizations = NA,
  active_icu = NA
)

# add provincial data
out[1, "cases"] <- readr::parse_number(tabs[[1]][1, 1])
out[1, "deaths"] <- readr::parse_number(tabs[[1]][2, 1])
out[1, "cumulative_recovered"] <- readr::parse_number(tabs[[1]][2, 3])
out[1, "active_cases"] <- readr::parse_number(tabs[[1]][2, 4])
out[1, "active_hospitalizations"] <- readr::parse_number(tabs[[2]][1, 1])
out[1, "active_icu"] <- readr::parse_number(tabs[[2]][2, 2])
out[1, "cumulative_cases"] <- readr::parse_number(tabs[[4]][11, 3]) # automatically extracts first number
out[1, "cumulative_deaths"] <- readr::parse_number(tabs[[4]][11, 4])

# add health region data
out[2:8, "cumulative_cases"] <- readr::parse_number(tabs[[4]][4:10, 3])
out[2:8, "cases"] <- readr::parse_number(tabs[[4]][4:10, 2])
out[2:8, "cumulative_deaths"] <- readr::parse_number(tabs[[4]][4:10, 4])

# check column sums
out[["cumulative_cases"]][1] == sum(out[["cumulative_cases"]][2:8])
out[["cases"]][1] == sum(out[["cases"]][2:8])
out[["cumulative_deaths"]][1] == sum(out[["cumulative_deaths"]][2:8])

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "nb_weekly_report")
