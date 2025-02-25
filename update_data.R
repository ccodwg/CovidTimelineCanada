# Update CovidTimelineCanada datasets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# Authentication: You must authenticate your Google account before running the rest of the script.
# You may be asked to give "Tidyverse API Packages" read/write access to your Google account.

# GitHub: This script assumes pre-existing authentication for pushing to the CovidTimelineCanada GitHub repository.

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

# # run update manually, skipping update of raw and extra datasets
# Covid19CanadaETL::ccodwg_update(skip_raw_update = TRUE, skip_extra_update = TRUE)

# check for updated files
system2("git", "update-index --really-refresh")
status <- system2("git", "diff-index --quiet HEAD --")
if (status == 0) {
  # exit without update
  cat("No files have changed. Exiting without update...", fill = TRUE)
} else {
  # print files that changed
  system2("git", "diff --name-only HEAD")
  # generate update time
  update_time <- Covid19CanadaETL::write_update_time()
  # stage data update
  cat("Staging files for update...", fill = TRUE)
  system2(
    command = "git",
    args = c("add",
             "data/",
             "diffs/",
             "extra_data/",
             "raw_data/",
             "update_time.txt"
    )
  )
  # commit data update
  cat("Creating commit...", fill = TRUE)
  system2(
    command = "git",
    args = c("commit",
             "-m",
             paste0("\"Update data: ", update_time, "\"")
    )
  )
  # push data update
  cat("Pushing data update...", fill = TRUE)
  system2(
    command = "git",
    args = c("push")
  )
  # report success
  cat("Data update successful!", fill = TRUE)
}
