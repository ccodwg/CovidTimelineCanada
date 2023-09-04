# Update Newfoundland & Labrador monthly deaths by epidemiological week data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# load dashboard dataset
url <- Covid19CanadaData::get_dataset_url("081099d5-cb0f-445d-ba00-78f63cc49800")
ds <- Covid19CanadaData::dl_dataset("081099d5-cb0f-445d-ba00-78f63cc49800")$features$attributes

# process data
tab <- dplyr::tibble(
  date = date_local,
  source = url,
  date_start = MMWRweek::MMWRweek2Date(as.integer(substr(ds$Epi_Week, 1, 4)), as.integer(substr(ds$Epi_Week, 7, 8))),
  date_end = date_start + 6,
  region = "NL",
  sub_region_1 = "",
  deaths = ds$Number_of_Deaths
)

# append data
googlesheets4::sheet_append(data = tab, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "nl_monthly_report")
