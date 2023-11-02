# Update PEI Respiratory Illness Summary data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_today <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# get data
tmp <- tempfile(fileext = ".html")
curl::curl_download("https://www.princeedwardisland.ca/en/information/health-and-wellness/pei-respiratory-illness-summary-2023-2024-season", tmp, quiet = TRUE, handle = curl::new_handle("useragent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"))
ds <- rvest::read_html(tmp)
tab <- rvest::html_table(ds, header = TRUE)

# construct output table
out <- dplyr::tibble(
  date = date_today,
  source = "https://www.princeedwardisland.ca/en/information/health-and-wellness/pei-respiratory-illness-summary-2023-2024-season",
  date_start = "", # manual
  date_end = "", # manual
  region = "PE",
  sub_region_1 = "",
  `cumulative_cases_since_2023-08-27` = as.integer(tab[[1]][2, 6]),
  `cumulative_cases_before_2023-08-27` = sum(as.integer(gsub(",", "", tab[[5]][["Total Cases"]]))),
  cumulative_cases = .data$`cumulative_cases_since_2023-08-27` + .data$`cumulative_cases_before_2023-08-27`,
  `cumulative_deaths_since_2023-08-27` = as.integer(tab[[4]][4, 4]),
  `cumulative_deaths_before_2023-08-27` = sum(as.integer(gsub(",", "", tab[[5]][["Deaths"]]))),
  cumulative_deaths = .data$`cumulative_deaths_since_2023-08-27` + .data$`cumulative_deaths_before_2023-08-27`,
  `cumulative_hosp_admissions_since_2023-08-27` = as.integer(tab[[4]][2, 4]),
  `cumulative_hosp_admissions_before_2023-08-27` = sum(as.integer(gsub(",", "", tab[[5]][["Hospitalized"]]))),
  `cumulative_hosp_admissions` = .data$`cumulative_hosp_admissions_since_2023-08-27` + .data$`cumulative_hosp_admissions_before_2023-08-27`,
  `cumulative_icu_admissions_since_2023-08-27` = as.integer(tab[[4]][3, 4]),
  `cumulative_icu_admissions_before_2023-08-27` = sum(as.integer(gsub(",", "", tab[[5]][["ICU"]]))),
  `cumulative_icu_admissions` = .data$`cumulative_icu_admissions_since_2023-08-27` + .data$`cumulative_icu_admissions_before_2023-08-27`,
  notes = NA
)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "pe_respiratory_illness_report")
