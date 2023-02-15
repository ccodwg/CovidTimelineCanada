# Update Nova Scotia weekly report dashboard data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_today <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# load weekly report dataset
ds <- Covid19CanadaData::dl_dataset("5d37261a-fcb0-46aa-ab53-9f86dccb2902")$features$attributes

# construct output table
out <- dplyr::tibble(
  date = date_today,
  source = "https://experience.arcgis.com/experience/204d6ed723244dfbb763ca3f913c5cad",
  date_start = NA, # fill manually
  date_end = NA, # fill manually
  region = "NS",
  sub_region_1 = NA,
  cases = NA,
  cumulative_deaths = NA,
  deaths = NA,
  deaths_current_reporting_period = NA,
  deaths_previous_reporting_period = NA,
  active_hospitalizations = NA,
  new_hospitalizations = NA,
  active_icu = NA,
  .rows = 2 # duplicate empty rows
)

# add case/death/testing data
out[1, "cases"] <- ds$POSPCR
out[1, "cumulative_deaths"] <- ds$D_TOTAL
out[1, "deaths"] <- ds$D_WEEK + ds$D_NEW
out[1, "deaths_current_reporting_period"] <- ds$D_WEEK
out[1, "deaths_previous_reporting_period"] <- ds$D_NEW
out[1, "new_hospitalizations"] <- ds$H_NEW_ADM

# add active hospitalization/ICU data
out[2, "active_hospitalizations"] <- ds$H_TOTAL
out[2, "active_icu"] <- ds$H_ICU

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "ns_weekly_report")
