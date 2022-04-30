# Update raw_data/reports #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# Authentication: You must authenticate your Google account before running the rest of the script.
# You may be asked to give "Tidyverse API Packages" read/write access to your Google account.

# authenticate with Google account (skip if already authenticated)
if (!googlesheets4::gs4_has_token()) {
  if (file.exists("/secrets.json")) {
    # use service account key to authenticate non-interactively, if it exists
    googlesheets4::gs4_auth(path = "/secrets.json")
  } else {
    # otherwise, prompt for authentication
    googlesheets4::gs4_auth()
  }
}

# function: sync file to "raw_data/reports" directory
sync_report <- function(sheet, region) {
  dir_path <- file.path("raw_data", "reports", region)
  dir.create(dir_path, showWarnings = FALSE)
  f_name <- paste0(sheet, ".csv")
  d <- googlesheets4::read_sheet(
    ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo",
    sheet = sheet
  )
  write.csv(
    d,
    file.path(dir_path, f_name),
    row.names = FALSE,
    na = "",
    quote = 1:6)
}

# actively updated reports
sync_report("mb_weekly_report", "mb")
sync_report("nb_weekly_report", "nb")
sync_report("ns_weekly_report", "ns")
sync_report("sk_weekly_report", "sk")

# no longer updated reports
sync_report("ns_daily_news_release", "ns")
sync_report("pe_daily_news_release", "pe")
