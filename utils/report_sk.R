# Update Saskatchewan weekly CRISP report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# make sure tabulizer is installed
# install.packages("rJava") # https://datawookie.dev/blog/2018/02/installing-rjava-on-ubuntu/
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- as.Date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# get epi week date ranges
most_recent_week <- MMWRweek::MMWRweek(date_local - 7)
most_recent_start <- MMWRweek::MMWRweek2Date(most_recent_week$MMWRyear, most_recent_week$MMWRweek, 1)
most_recent_end <- MMWRweek::MMWRweek2Date(most_recent_week$MMWRyear, most_recent_week$MMWRweek, 7)
date_start <- c(most_recent_start - 21, most_recent_start - 14, most_recent_start - 7, most_recent_start)
date_end <- c(most_recent_end - 21, most_recent_end - 14, most_recent_end - 7, most_recent_end)

# load report
ds <- tempfile()
url <- Covid19CanadaData::dl_dataset_dyn_url("b22d4896-160d-432b-b02a-ba933d14a58a")
download.file(url, ds)

# define template for one week of data
week <- data.frame(
  date = date_local,
  source = url,
  date_start = NA,
  date_end = NA,
  region = "SK",
  sub_region_1 = c(
    "",
    "Far North West",
    "Far North Central",
    "Far North East",
    "North West",
    "North Central",
    "North East",
    "Saskatoon",
    "Central West",
    "Central East",
    "Regina",
    "South West",
    "South Central",
    "South East",
    "Unknown"),
  cases = NA,
  deaths = NA,
  new_hospitalizations = NA,
  new_icu = NA,
  positivity_rate = NA
)

# extract text and tables
tables <- tabulizer::extract_tables(ds)

# week 1
week_1 <- week
week_1$date_start <- date_start[1]
week_1$date_end <- date_end[1]
week_1[week_1$sub_region_1 %in% c("", "Unknown"), c("cases")] <-
  as.integer(tables[[1]][7, 2])
week_1[week_1$sub_region_1 %in% c("", "Unknown"), c("positivity_rate")] <-
  readr::parse_number(tables[[1]][7, 3]) # takes the first number in the cell, which is test positivity
week_1[week_1$sub_region_1 %in% c("", "Unknown"), c("deaths")] <-
  readr::parse_number(tables[[3]][8, 11])
week_1[week_1$sub_region_1 == "", "new_hospitalizations"] <-
  as.integer(stringr::str_extract(tables[[3]][8, 1], "\\d*$")) # takes last number in the cell, which is new hospitalizations
week_1[week_1$sub_region_1 == "", "new_icu"] <-
  as.integer(tables[[3]][8, 2])

# week 2
week_2 <- week
week_2$date_start <- date_start[2]
week_2$date_end <- date_end[2]
week_2[week_2$sub_region_1 %in% c("", "Unknown"), c("cases")] <-
  as.integer(tables[[1]][6, 2])
week_2[week_2$sub_region_1 %in% c("", "Unknown"), c("positivity_rate")] <-
  readr::parse_number(tables[[1]][6, 3]) # takes the first number in the cell, which is test positivity
week_2[week_2$sub_region_1 %in% c("", "Unknown"), c("deaths")] <-
  readr::parse_number(tables[[3]][7, 11])
week_2[week_2$sub_region_1 == "", "new_hospitalizations"] <-
  as.integer(stringr::str_extract(tables[[3]][7, 1], "\\d*$")) # takes last number in the cell, which is new hospitalizations
week_2[week_2$sub_region_1 == "", "new_icu"] <-
  as.integer(tables[[3]][7, 2])

# week 3
week_3 <- week
week_3$date_start <- date_start[3]
week_3$date_end <- date_end[3]
week_3[week_3$sub_region_1 %in% c("", "Unknown"), c("cases")] <-
  as.integer(tables[[1]][5, 2])
week_3[week_3$sub_region_1 %in% c("", "Unknown"), c("positivity_rate")] <-
  readr::parse_number(tables[[1]][5, 3]) # takes the first number in the cell, which is test positivity
week_3[week_3$sub_region_1 %in% c("", "Unknown"), c("deaths")] <-
  readr::parse_number(tables[[3]][6, 11])
week_3[week_3$sub_region_1 == "", "new_hospitalizations"] <-
  as.integer(stringr::str_extract(tables[[3]][6, 1], "\\d*$")) # takes last number in the cell, which is new hospitalizations
week_3[week_3$sub_region_1 == "", "new_icu"] <-
  as.integer(tables[[3]][6, 2])

# week 4
week_4 <- week
week_4$date_start <- date_start[4]
week_4$date_end <- date_end[4]
week_4[week_4$sub_region_1 %in% c("", "Unknown"), c("cases")] <-
  as.integer(tables[[1]][4, 2])
week_4[week_4$sub_region_1 %in% c(""), c("positivity_rate")] <-
  readr::parse_number(tables[[1]][4, 3]) # takes the first number in the cell, which is test positivity
week_4[week_4$sub_region_1 %in% c("", "Unknown"), c("deaths")] <-
  readr::parse_number(tables[[3]][5, 11])
week_4[week_4$sub_region_1 == "", "new_hospitalizations"] <-
  as.integer(stringr::str_extract(tables[[3]][5, 1], "\\d*$")) # takes last number in the cell, which is new hospitalizations
week_4[week_4$sub_region_1 == "", "new_icu"] <-
  as.integer(tables[[3]][5, 2])
week_4[week_4$sub_region_1 != "Unknown", "positivity_rate"] <- readr::parse_number(tables[[4]][c(15, 2:14), 2])

# combine data
out <- rbind(week_1, week_2, week_3, week_4)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "sk_crisp_report")
