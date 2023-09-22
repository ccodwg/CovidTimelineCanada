# Update Ontario Public Health Ontario data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# calls functions from the Python script utils/report_on.py
# ensure that Python code can be run with the "reticulate" R package
# https://rstudio.github.io/reticulate/

# import script
report_on <- reticulate::source_python("utils/report_on.py")

# authorize with Google Sheets
googlesheets4::gs4_auth()

# prompt for valid EmbedToken
# user input: embed token from authorization header of network request to download XLSX data from figure
auth = readline()

# get end date
# one day greater than max date on dashboard, which should be two Mondays ago
end_date <- as.Date(lubridate::with_tz(Sys.time(), "America/Toronto")) - 11
end_date <- paste0("datetime'", end_date, "T00:00:00'") # format end date

# define options
ua <- 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36'
aid <- uuid::UUIDgenerate()
start_date <- "datetime'2020-01-01T00:00:00'"
hr <- c(
  "Ontario",
  "Algoma Public Health",
  "Brant County Health Unit",
  "Chatham-Kent Public Health",
  "City of Hamilton Public Health Services",
  "Durham Region Health Department",
  "Eastern Ontario Health Unit",
  "Grey Bruce Health Unit",
  "Haldimand-Norfolk Health Unit",
  "Haliburton, Kawartha, Pine Ridge District Health Unit",
  "Halton Region Public Health",
  "Hastings Prince Edward Public Health",
  "Huron Perth Public Health",
  "Kingston, Frontenac and Lennox & Addington Public Health",
  "Lambton Public Health",
  "Leeds, Grenville & Lanark District Health Unit",
  "Middlesex-London Health Unit",
  "Niagara Region Public Health",
  "North Bay Parry Sound District Health Unit",
  "Northwestern Health Unit",
  "Ottawa Public Health",
  "Peel Public Health",
  "Peterborough Public Health",
  "Porcupine Health Unit",
  "Public Health Sudbury & Districts",
  "Region of Waterloo Public Health and Emergency Services",
  "Renfrew County and District Health Unit",
  "Simcoe Muskoka District Health Unit",
  "Southwestern Public Health",
  "Thunder Bay District Health Unit",
  "Timiskaming Health Unit",
  "Toronto Public Health",
  "Wellington-Dufferin-Guelph Public Health",
  "Windsor-Essex County Health Unit",
  "York Region Public Health"
)
hr <- paste0("'", hr, "'")

# case data
dat_cases <- dplyr::bind_rows(lapply(seq_along(hr), function(x) {
  tmp <- tempfile()
  on_case_data(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_cases <- dat_cases |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`Week end date` - 6,
    date_end = .data$`Week end date`,
    .data$region,
    .data$sub_region_1,
    cases_weekly = .data$`Number of cases`,
    cases_weekly_per_100k = .data$`Cases per 100,000 population`,
    population = .data$Population
  )

# outcome data
dat_outcomes <- dplyr::bind_rows(lapply(seq_along(hr), function(x) {
  tmp <- tempfile()
  on_outcome_data(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
                    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_outcomes <- dat_outcomes |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`Week end date` - 6,
    date_end = .data$`Week end date`,
    .data$region,
    .data$sub_region_1,
    outcome_weekly_type = .data$`Selected outcomes`,
    outcome_weekly_value = .data$Number
  )

# testing data (Ontario only)
dat_testing <- dplyr::bind_rows(lapply(seq_along(hr[1]), function(x) {
  tmp <- tempfile()
  on_testing_data(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
                    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_testing <- dat_testing |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`Week start date`,
    date_end = .data$`Week start date` + 6,
    .data$region,
    .data$sub_region_1,
    tests_completed_weekly = .data$`Total number of tests`,
    tests_positive_weekly = .data$`Total number of positive tests`,
    percent_positivity_weekly = .data$`Percent positivity (%)`
  )

# vaccine doses
dat_doses <- dplyr::bind_rows(lapply(seq_along(hr), function(x) {
  tmp <- tempfile()
  on_vaccine_dose_data(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
                    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_doses <- dat_doses |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`'vaxdosevaxdata'[Week start date]`,
    date_end = .data$`'vaxdosevaxdata'[Week start date]` + 6,
    .data$region,
    .data$sub_region_1,
    dose_weekly_type = .data$`Dose number`,
    dose_weekly_value = .data$`Number of doses`
  )

# vaccine coverage
dat_coverage_1 <- dplyr::bind_rows(lapply(seq_along(hr), function(x) {
  tmp <- tempfile()
  on_vaccine_coverage_data_1(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
                    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_coverage_1 <- dat_coverage_1 |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`Week end date` - 6,
    date_end = .data$`Week end date`,
    .data$region,
    .data$sub_region_1,
    coverage_type = .data$`Vaccination status`,
    coverage_cum_percent = .data$`Cumulative coverage estimate (%)`
  )
dat_coverage_2 <- dplyr::bind_rows(lapply(seq_along(hr), function(x) {
  tmp <- tempfile()
  on_vaccine_coverage_data_2(tmp, auth, aid, ua, start_date, end_date, hr[x])
  d <- readxl::read_xlsx(tmp, skip = 2)
  hr_name <- ifelse(hr[x] == "'Ontario'", "",
                    substr(hr[x], 2, nchar(hr[x]) - 1))
  d <- dplyr::mutate(
    d,
    region = "ON",
    sub_region_1 = hr_name,
    .before = 1)
}))
dat_coverage_2 <- dat_coverage_2 |>
  dplyr::mutate(dplyr::across(where(lubridate::is.POSIXct), as.Date)) |>
  dplyr::transmute(
    date_start = .data$`Week end date` - 6,
    date_end = .data$`Week end date`,
    .data$region,
    .data$sub_region_1,
    coverage_type = .data$`Vaccination status`,
    coverage_cum_individuals = .data$`Cumulative number of individuals vaccinated`
  )
dat_coverage <- dplyr::left_join(
  dat_coverage_1, dat_coverage_2, by = c("date_start", "date_end", "region", "sub_region_1", "coverage_type"))

# sync data to Google Sheets
googlesheets4::write_sheet(data = dat_cases, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "on_pho_cases")
googlesheets4::write_sheet(data = dat_outcomes, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "on_pho_outcomes")
googlesheets4::write_sheet(data = dat_testing, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "on_pho_testing")
googlesheets4::write_sheet(data = dat_doses, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "on_pho_vaccine_doses")
googlesheets4::write_sheet(data = dat_coverage, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "on_pho_vaccine_coverage")
