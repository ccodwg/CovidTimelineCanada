# Update Saskatchewan weekly CRISP report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# make sure the Python package "Camelot" is installed along with all dependencies
# also ensure that Python code can be run with the "reticulate" R package
# https://camelot-py.readthedocs.io/en/master/user/install.html
# https://rstudio.github.io/reticulate/

# authorize with Google Sheets
googlesheets4::gs4_auth()

# import camelot
camelot <- reticulate::import("camelot")

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# get epi week date ranges
most_recent_week <- MMWRweek::MMWRweek(date_local - 7)
most_recent_start <- MMWRweek::MMWRweek2Date(most_recent_week$MMWRyear, most_recent_week$MMWRweek, 1)
most_recent_end <- MMWRweek::MMWRweek2Date(most_recent_week$MMWRyear, most_recent_week$MMWRweek, 7)
date_start <- c(most_recent_start - 21, most_recent_start - 14, most_recent_start - 7, most_recent_start)
date_end <- c(most_recent_end - 21, most_recent_end - 14, most_recent_end - 7, most_recent_end)

# load report
ds <- file.path(tempdir(), "sk_report_temp.pdf")
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

# extract tables
tables <- camelot$read_pdf(ds, pages = "all")
tables <- lapply(seq_along(tables) - 1, function(i) tables[i]$df)

# identify relevant tables
identify_table <- function(x) {
  # extract first row of each table (headers) - stripping out newline
  h <- lapply(tables, function(x) gsub("\n", "", x[1, ]))
  # grep to identify table
  i <- grep(x, h)
  # check result and return table
  if (length(i) == 0) {
    stop("Failed to identify table.")
  } else if (length(i) > 1) {
    stop("Table not uniquely identified.")
  } else {
    # return table
    tables[[i]]
    }
}
tab_cases <- identify_table("COVID-19 positive")
tab_outcomes <- identify_table("Deaths \u2013 COVID-19")
tab_zone <- identify_table("Location")

# extract data for each week
extract_week_data <- function(i) {
  w <- week # copy week template
  w$date_start <- date_start[i]
  w$date_end <- date_end[i]
  w[w$sub_region_1 %in% c("", "Unknown"), c("cases")] <-
    as.integer(tab_cases[5 - (i - 1), 2])
  w[w$sub_region_1 %in% c("", "Unknown"), c("positivity_rate")] <-
    readr::parse_number(tab_cases[5 - (i - 1), 3])
  w[w$sub_region_1 %in% c("", "Unknown"), c("deaths")] <-
    as.integer(tab_outcomes[5 - (i - 1), 9])
  w[w$sub_region_1 == "", "new_hospitalizations"] <-
    as.integer(tab_outcomes[5 - (i - 1), 2])
  w[w$sub_region_1 == "", "new_icu"] <-
    as.integer(tab_outcomes[5 - (i - 1), 3])
  # return table
  w
}
week_1 <- extract_week_data(1)
week_2 <- extract_week_data(2)
week_3 <- extract_week_data(3)
week_4 <- extract_week_data(4)

# extract health region percent positivity for most recent week
# unknown health region test positivity only appeared beginning with the report released 2022-12-29
# was previously included in calculation of province-level test positivity but not separated out
week_4[week_4$sub_region_1 == "Unknown", "positivity_rate"] <- readr::parse_number(
  tab_zone[16, 2]) # update unknown
week_4[week_4$sub_region_1 == "", "positivity_rate"] <- readr::parse_number(
  tab_zone[17, 2]) # update province (unnecessary)
week_4[!week_4$sub_region_1 %in% c("", "Unknown"), "positivity_rate"] <- readr::parse_number(
  tab_zone[3:15, 2]) # extract health regions

# extract health region cases for most recent week
# health region cases only appeared beginning with the report released 2023-01-06
week_4[week_4$sub_region_1 == "Unknown", "cases"] <- as.integer(
  stringr::str_extract(tab_zone[16, 2], "(\\d+)(?!.*\\d)"))
week_4[!week_4$sub_region_1 %in% c("", "Unknown"), "cases"] <- as.integer(
  stringr::str_extract(tab_zone[3:15, 2], "(\\d+)(?!.*\\d)"))

# check if health region cases sum matches provincial cases
sum(week_4$cases[2:15]) == week_4$cases[1] # should be TRUE

# combine data
out <- rbind(week_1, week_2, week_3, week_4)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "sk_crisp_report")
