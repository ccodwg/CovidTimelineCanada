# Update New Brunswick weekly report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# make sure tabulizer is installed
# install.packages("rJava") # https://datawookie.dev/blog/2018/02/installing-rjava-on-ubuntu/
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))

# make sure the Python package "Camelot" is installed along with all dependencies
# also ensure that Python code can be run with the "reticulate" R package
# https://camelot-py.readthedocs.io/en/master/user/install.html
# https://rstudio.github.io/reticulate/

# load pipe
library(magrittr)

# authorize with Google Sheets
googlesheets4::gs4_auth()

# import camelot
camelot <- reticulate::import("camelot")

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# load report
ds <- file.path(tempdir(), "nb_report_temp.pdf")
url <- rvest::read_html("https://www2.gnb.ca/content/gnb/en/corporate/promo/covid-19/COVIDWATCH.html") %>%
  rvest::html_elements("a") %>%
  {paste0("https://www2.gnb.ca", rvest::html_attr(.[grep("Full Report", rvest::html_text2(.))][1], "href"))}
download.file(url, ds)

# extract text and tables from relevant pages
tables <- camelot$read_pdf(ds, pages = "all")
tables <- lapply(seq_along(tables) - 1, function(i) tables[i]$df)
text <- tabulizer::extract_text(ds, pages = 1)

# extract week and generate date_start and date_end
epi_week <- readr::parse_number(gsub(" ", "", stringr::str_extract(text, "\\( W E E K.*\\)")))
date_start <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week)
date_end <- MMWRweek::MMWRweek2Date(lubridate::year(date_local), epi_week) + 6

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
tab_summary <- identify_table("Number in reporting week")
tab_region <- identify_table("Region")

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
out[1, "cases_weekly"] <- as.integer(tab_summary[3, 2])
out[1, "cumulative_cases_since_2022-08-28"] <- as.integer(tab_summary[3, 4])
out[1, "deaths_weekly"] <- as.integer(tab_summary[6, 2])
out[1, "cumulative_deaths_since_2022-08-28"] <- as.integer(tab_summary[6, 4])
out[1, "new_hospitalizations_weekly"] <- as.integer(tab_summary[4, 2])
out[1, "cumulative_new_hospitalizations_since_2022-08-28"] <- as.integer(tab_summary[4, 4])
out[1, "new_icu_weekly"] <- as.integer(tab_summary[5, 2])
out[1, "cumulative_new_icu_since_2022-08-28"] <- as.integer(tab_summary[5, 4])
out[1, "tests_completed_weekly"] <- as.integer(tab_summary[2, 2])
out[1, "cumulative_tests_completed_since_2022-08-28"] <- as.integer(tab_summary[2, 4])

# add health region data
out[2:8, "cases_weekly"] <- as.integer(tab_region[2:8, 3])
out[2:8, "new_hospitalizations_weekly"] <- as.integer(tab_region[2:8, 4])
out[2:8, "new_icu_weekly"] <- as.integer(tab_region[2:8, 5])
out[2:8, "tests_completed_weekly"] <- as.integer(tab_region[2:8, 2])

# check column sums
out[["cases_weekly"]][1] == sum(out[["cases_weekly"]][2:8])
out[["new_hospitalizations_weekly"]][1] == sum(out[["new_hospitalizations_weekly"]][2:8])
out[["new_icu_weekly"]][1] == sum(out[["new_icu_weekly"]][2:8])
out[["tests_completed_weekly"]][1] == sum(out[["tests_completed_weekly"]][2:8])

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "nb_weekly_report_2")
