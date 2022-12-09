# Update Manitoba weekly report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load pipe
library(magrittr)

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- as.Date(lubridate::with_tz(Sys.time(), "America/Toronto"))
epi_year <- lubridate::year(date_local - 6) # year from previous epi week

# get epi week
url <- Covid19CanadaData::dl_dataset_dyn_url("211a55f7-3050-48b6-9cf0-6a76595733c3")
epi_week <- as.integer(stringr::str_extract(url, "(?<=week_)(\\d+)"))
date_start <- MMWRweek::MMWRweek2Date(epi_year, epi_week)
date_end <- date_start + 6

# load report
ds <- rvest::read_html(url)

# extract data
tb_cases <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_cases", .)]} %>% rvest::html_table() %>% dplyr::nth(1)
tb_severity <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_severity", .)]} %>% rvest::html_table() %>% dplyr::nth(1)
tb_testing <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_testing", .)]} %>% rvest::html_table() %>% dplyr::nth(1)
tb_hr <- ds %>% rvest::html_table() %>% {.[grep("Health Region|Helath region", .)]} %>% dplyr::nth(1)

# function: extract number from specific substring in specific row of an HTML table
extract_from_tab <- function(tab, row_n, string, parse_num = TRUE) {
  x <- tab %>%
    dplyr::slice(n = row_n) %>%
    gsub("[\r\n]", " ", .) %>% # newline characters mess up regex
    gsub(",", "", .) %>%
    stringr::str_extract(string)
  if (parse_num) {
    readr::parse_number(x)
  } else {
    trimws(x)
  }
}

# assemble data
mb <- dplyr::bind_rows(
  dplyr::tibble(
    date = date_local,
    source = url,
    date_start = date_start,
    date_end = date_end,
    region = "MB",
    sub_region_1 = NA,
    cases = NA, # calculated by formula
    cases_weekly = extract_from_tab(tb_cases, 2, "Cases this week: \\d*"),
    `cumulative_cases_2022-07-03` = extract_from_tab(tb_cases, 2, "Total cases: \\d*"),
    `cumulative_cases_2022-07-03_weekly_diff` = NA, # calculated by formula
    deaths_weekly = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Deaths: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_deaths_since_2022-07-03` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}Deaths: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_hospitalizations_since_2022-07-03` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}Hospital admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    new_hospitalizations = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Hospital admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_icu_since_2022-07-03` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}ICU admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    new_icu = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}ICU admissions[\\d]{0,1}: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_tests_completed_2022-07-03` = extract_from_tab(tb_testing, 2, "Specimens tested: \\d*"),
    new_tests_completed_daily = extract_from_tab(tb_testing, 2, "Average daily specimens: \\d*"),
    positivity_rate_weekly = extract_from_tab(tb_testing, 2, "Weekly positivity rate: \\d*\\.\\d*(?=%)"),
    `cumulative_people_tested_2022-07-03` = extract_from_tab(tb_testing, 2, "Tested people: \\d*")
  ),
  dplyr::tibble(
    date = date_local,
    source = url,
    date_start = date_start,
    date_end = date_end,
    region = "MB",
    sub_region_1 = tb_hr %>% dplyr::pull(1),
    `cumulative_cases_2022-07-03` = tb_hr %>% dplyr::pull("Total cases") %>% as.character() %>% readr::parse_number(),
    cases_weekly = tb_hr %>% dplyr::pull("Cases this week") %>% as.character() %>% readr::parse_number()
  )
)

# convert character columns to numeric, as necessary
for (i in 1:ncol(mb)) {
  if (is.character(mb[, i, drop = TRUE]) & !is.na(as.numeric(mb[1, i, drop = TRUE]))) {
    print(i)
    mb[, i, drop = TRUE] <- as.numeric(mb[, i, drop = TRUE])
  }
}

# check column sums
mb[["cumulative_cases_2022-07-03"]][1] == sum(mb[["cumulative_cases_2022-07-03"]][2:6])
mb[["cases_weekly"]][1] == sum(mb[["cases_weekly"]][2:6])

# append data
googlesheets4::sheet_append(data = mb, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "mb_weekly_report_2")
