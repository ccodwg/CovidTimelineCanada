# Update Manitoba weekly report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load pipe
library(magrittr)

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))
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

# function: extract number from specific substring in specific row of an HTML table
extract_from_tab <- function(tab, row_n, string, parse_num = TRUE) {
  x <- tab %>%
    dplyr::slice(row_n) %>%
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
    cases_weekly = extract_from_tab(tb_cases, 2, "(?<=Cases this week: )\\d*", parse_num = FALSE),
    `cumulative_cases_since_2022-07-03` = NA,
    `cumulative_cases_since_2022-07-03_weekly_diff` = NA,
    `cumulative_cases_since_2023-07-02` = extract_from_tab(tb_cases, 2, "(?<=Total cases: )\\d*", parse_num = FALSE),
    `cumulative_cases_since_2023-07-02_weekly_diff` = NA, # calculated by formula
    deaths_weekly = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Deaths: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_deaths_since_2022-07-03` = NA,
    `cumulative_deaths_since_2023-07-02` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}Deaths: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_hospitalizations_diff` = NA, # calculated by formula
    `cumulative_hospitalizations_since_2022-07-03` = NA,
    `cumulative_hospitalizations_since_2022-07-03_diff` = NA,
    `cumulative_hospitalizations_since_2023-07-02` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}Hospital admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_hospitalizations_since_2023-07-02_diff` = NA, # calculated by formula
    new_hospitalizations = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Hospital admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_icu_diff` = NA, # calculated by formula
    `cumulative_icu_since_2022-07-03` = NA,
    `cumulative_icu_since_2022-07-03_diff` = NA,
    `cumulative_icu_since_2023-07-02` = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000}ICU admissions: ).{1,5}(?!\r)", parse_num = FALSE),
    `cumulative_icu_since_2023-07-02_diff` = NA, # calculated by formula
    new_icu = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}ICU admissions[\\d]{0,1}: ).{1,5}(?!\r)", parse_num = FALSE),
    `tests_completed` = NA, # calculated by formula
    `cumulative_tests_completed_2022-07-03` = NA,
    `cumulative_tests_completed_2022-07-03_diff` = NA,
    `cumulative_tests_completed_2023-07-02` = extract_from_tab(tb_testing, 2, "Specimens tested: \\d*"),
    `cumulative_tests_completed_2023-07-02_diff` = NA, # calculated by formula
    new_tests_completed_daily = extract_from_tab(tb_testing, 2, "Average daily specimens: \\d*"),
    positivity_rate_weekly = extract_from_tab(tb_testing, 2, "Weekly positivity rate: \\d*\\.\\d*(?=%)"),
    `cumulative_people_tested_2022-07-03` = NA,
    `cumulative_people_tested_2023-07-02` = extract_from_tab(tb_testing, 2, "Tested people: \\d*"),
    notes = NA
  )
)

# convert character columns to numeric, as necessary
for (i in 1:ncol(mb)) {
  if (is.character(mb[, i, drop = TRUE]) & all(((is.na(mb[, i, drop = TRUE])) | !is.na(as.numeric(mb[, i, drop = TRUE]))))) {
    print(i)
    mb[, i, drop = TRUE] <- as.numeric(mb[, i, drop = TRUE])
  }
}

# add health region rows to be filled in manually from figure 3
mb <- dplyr::bind_rows(
  mb,
  data.frame(
    date = date_local,
    source = url,
    date_start = date_start,
    date_end = date_end,
    region = "MB",
    sub_region_1 = c(
    "Winnipeg RHA",
    "Southern Health-Santé Sud",
    "Interlake-Eastern RHA",
    "Prairie Mountain Health",
    "Northern Health Region")
  )
)

# append data
googlesheets4::sheet_append(data = mb, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "mb_weekly_report_2")
