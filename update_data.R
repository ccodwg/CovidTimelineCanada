# Update CovidTimelineCanada datasets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# Authentication: You must authenticate your Google account before running the rest of the script.
# You may be asked to give "Tidyverse API Packages" read/write access to your Google account.

# run update
if (file.exists("/secrets.json")) {
  # use service account key, if it exists
  Covid19CanadaETL::ccodwg_update(path = "/secrets.json")
} else if (exists("email")) {
  # use email variable, if it exists
  Covid19CanadaETL::ccodwg_update(email = email)
} else {
  # otherwise, prompt for authentication
  Covid19CanadaETL::ccodwg_update()
}
