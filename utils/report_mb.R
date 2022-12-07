# Update Manitoba weekly report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load pipe
library(magrittr)

# authorize with Google Sheets
googlesheets4::gs4_auth()

# load webpage and extract datasets
date_local <- as.Date(lubridate::with_tz(Sys.time(), "America/Toronto"))
ds <- rvest::read_html("https://www.gov.mb.ca/health/publichealth/surveillance/covid-19/index.html")
week_links <- ds %>% {rvest::html_elements(., "a")[grepl("Week ", rvest::html_elements(., "a") %>% rvest::html_text2())]}
epi_week <- week_links[1] %>% rvest::html_text2() %>% stringr::str_extract("\\d*$")
# week_url <- week_links[1] %>% rvest::html_attr("href") # link is sometimes to wrong week
week_url <- paste(lubridate::year(date_local), paste0("week_", epi_week), "index.html", sep = "/")
current_url <- paste0("https://www.gov.mb.ca/health/publichealth/surveillance/covid-19/", week_url)
ds <- rvest::read_html(current_url)
date_start <- MMWRweek::MMWRweek2Date(as.numeric(substr(week_url, 1, 4)), as.numeric(epi_week))
date_end <- MMWRweek::MMWRweek2Date(as.numeric(substr(week_url, 1, 4)), as.numeric(epi_week)) + 6
tb_cases <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_cases", .)]} %>% rvest::html_table() %>% dplyr::nth(1)
tb_severity <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_severity", .)]} %>% rvest::html_table() %>% dplyr::nth(1)
tb_testing <- ds %>% rvest::html_elements(".tgN") %>% {.[grep("tb_testing", .)]} %>% rvest::html_table() %>% dplyr::nth(1)

# function: extract number from specific substring in specific row of an HTML table
extract_from_tab <- function(tab, row_n, string) {
  tab %>%
    dplyr::slice(n = row_n) %>%
    gsub("[\r\n]", " ", .) %>% # newline characters mess up regex
    gsub(",", "", .) %>%
    stringr::str_extract(string) %>%
    readr::parse_number()
}

# assemble data
mb <- dplyr::bind_rows(
  dplyr::tibble(
    date = date_local,
    source = current_url,
    date_start = date_start,
    date_end = date_end,
    region = "MB",
    sub_region_1 = NA,
    cumulative_cases = extract_from_tab(tb_cases, 2, "Total cases: \\d*"),
    cases = extract_from_tab(tb_cases, 2, "Cases this week: \\d*"),
    cumulative_deaths = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000})Deaths: \\d*"),
    deaths = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Deaths\\d?: )\\d*"),
    cumulative_hospitalizations = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000})Hospital admissions: \\d*"),
    new_hospitalizations = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}Hospital admissions\\d?: )\\d*"),
    cumulative_icu = extract_from_tab(tb_severity, 2, "(?<=Total severe outcomes.{0,1000})ICU admissions: \\d*"),
    new_icu = extract_from_tab(tb_severity, 2, "(?<=Severe outcomes this week.{0,1000}ICU admissions\\d?: )\\d*"),
    cumulative_tests_completed = extract_from_tab(tb_testing, 2, "Specimens tested: \\d*"),
    new_tests_completed_daily = extract_from_tab(tb_testing, 2, "Average daily specimens: \\d*"),
    positivity_rate_weekly = extract_from_tab(tb_testing, 2, "Weekly positivity rate: \\d*\\.\\d*(?=%)"),
    cumulative_people_tested = extract_from_tab(tb_testing, 2, "Tested people: \\d*")
  ),
  dplyr::tibble(
    date = date_local,
    source = current_url,
    date_start = date_start,
    date_end = date_end,
    region = "MB",
    sub_region_1 = ds %>% rvest::html_table() %>% {.[grep("Health Region", .)]} %>% dplyr::nth(1) %>% dplyr::pull("Health Region"),
    cumulative_cases = ds %>% rvest::html_table() %>% {.[grep("Health Region", .)]} %>% dplyr::nth(1) %>% dplyr::pull("Total Cases") %>% as.character() %>% readr::parse_number(),
    cases = ds %>% rvest::html_table() %>% {.[grep("Health Region", .)]} %>% dplyr::nth(1) %>% dplyr::pull("Cases this week") %>% as.character() %>% readr::parse_number()
  )
)

# check column sums
mb[["cumulative_cases"]][1] == sum(mb[["cumulative_cases"]][2:6])
mb[["cases"]][1] == sum(mb[["cases"]][2:6])

# append data
googlesheets4::sheet_append(data = mb, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "mb_weekly_report")
