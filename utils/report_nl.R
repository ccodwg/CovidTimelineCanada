# Update Newfoundland & Labrador weekly respiratory report data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_today <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# get dates for most recent epi week
epi_week <- MMWRweek::MMWRweek(date_today - 7)
date_start <- MMWRweek::MMWRweek2Date(epi_week$MMWRyear, epi_week$MMWRweek)
date_end <- date_start + 6

### HR-LEVEL DEATHS AND HOSP/ICU ADMISSIONS ###

# load dashboard data
d <- Covid19CanadaData::dl_dataset("b199a8fe-5d60-46cc-8663-063326b41439")$features$attributes

# format data
out <- dplyr::tibble(
  date = date_today,
  source = "https://experience.arcgis.com/experience/6a9eae0871b94de1bcc67f6426a1abdf",
  date_start = date_start,
  date_end = date_end,
  region = "NL",
  sub_region_1 = "",
  deaths_current_period = d$Deaths__Current_Reporting_Perio,
  death_previous_period = d$Deaths__Added_From_Previous_Rep,
  deaths = .data$deaths_current_period + .data$death_previous_period,
  hosp_admissions = d$Hospitalizations__Current_Repor,
  icu_admissions = d$Critical_Care__Current_Reportin
)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "nl_respiratory_report")
