# Sync selected files to Google Drive #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# Authentication: You must authenticate your Google account before running the rest of the script.
# You may be asked to give "Tidyverse API Packages" read/write access to your Google account.

# load pipe
library(magrittr)

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

# sync legacy-formatted HR case and death datasets
tryCatch(
  readr::read_csv("https://api.opencovid.ca/timeseries?stat=cases&geo=hr&legacy=true&fmt=csv",
                  col_types = "cccii") %>%
    googlesheets4::sheet_write(ss = "10TJF5w1One2g6csGLnIA3j8Tc2ZRzXBfFNIWtyxumrU", sheet = 1),
  error = function(e) {print(e); cat("Upload failed: cases_hr_legacy", fill = TRUE)}
)
tryCatch(
  readr::read_csv("https://api.opencovid.ca/timeseries?stat=deaths&geo=hr&legacy=true&fmt=csv",
                  col_types = "cccii") %>%
    googlesheets4::sheet_write(ss = "10tLdzjTNo3G2gZikIkA3fRj91oqwF7BmJThW8hUAX3A", sheet = 1),
  error = function(e) {print(e); cat("Upload failed: deaths_hr_legacy", fill = TRUE)}
)
