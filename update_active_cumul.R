# Update raw_data/cumul_ts #
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

# function: sync file to "raw_data/active_cumul" directory
sync_active_cumul <- function(sheet, val, regions) {
  # load sheet
  d <- googlesheets4::read_sheet(
    ss = "14b_aksEvD3s_yonmG43rChCuL4u45qVsS2GmhUdiRd0",
    sheet = sheet)
  # format data frame
  d <- d %>%
    # ensure all relevant columns are character for writing
    dplyr::mutate(across(!dplyr::matches("date"), as.character)) %>%
    # wide to long format
    tidyr::pivot_longer(
      cols = !dplyr::matches("region|sub_region_1|sub_region_2"),
      names_to = "date",
      values_to = "value") %>%
    # drop empty values
    dplyr::filter(!is.na(.data$value)) %>%
    # arrange data
    dplyr::arrange(dplyr::across(dplyr::matches("region|sub_region_1|sub_region_2|date"))) %>%
    # add column with value name
    dplyr::mutate(name = val, .before = 1)
  # subset and write file for each region
  for (r in regions) {
    dir_path <- file.path("raw_data", "active_cumul", tolower(r))
    dir.create(dir_path, showWarnings = FALSE)
    f_name <- paste0(tolower(r), "_", sheet, "_ts.csv")
    d %>%
      dplyr::filter(.data$region == r) %>%
      utils::write.csv(
        file.path(dir_path, f_name),
        row.names = FALSE,
        quote = 1:(ncol(d) - 1))
  }
}

# death data
sync_active_cumul("deaths_hr", "deaths", c("AB", "BC", "NL"))
