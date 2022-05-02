# Update raw_data/active_ts, raw_data/ccodwg, raw_data/covid19tracker #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# Authentication: You must authenticate your Google account before running the rest of the script.
# You may be asked to give "Tidyverse API Packages" read/write access to your Google account.

# load pipe
library(magrittr)

# source functions
source("funs.R")

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

# define constants
pt <- c(
  "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT")

# download required datasets

## list datasets by region
covid_datasets <- list(
  # ab
  "59da1de8-3b4e-429a-9e18-b67ba3834002", # c
  # bc
  "ab6abe51-c9b1-4093-b625-93de1ddb6302", # c
  # can
  "f7db31d0-6504-4a55-86f7-608664517bdb", # c/d
  # mb
  # nb
  # nl
  "b19daaca-6b32-47f5-944f-c69eebd63c07", # c
  # ns
  # nt
  # nu
  # on
  "73fffd44-fbad-4de8-8d32-00cc5ae180a6", # c/d
  "4b214c24-8542-4d26-a850-b58fc4ef6a30", # h/i
  # pe
  # qc
  "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5", # c/d
  "f0c25e20-2a6c-4f9a-adc3-61b28ab97245", # h/i
  # sk
  # yt
  "8eb9a22f-a2c0-4bdb-8f6c-ef8134901efe" # c
)

## download datasets and name according to UUID
ds <- lapply(covid_datasets, FUN = function(x) {
  d <- Covid19CanadaData::dl_dataset(x)
  cat(x, fill = TRUE)
  return(d)}
)
names(ds) <- covid_datasets

# function: write processed data to "raw_data/active_ts" directory
write_active <- function(d, region, val, geo_level = c("pt", "hr", "sub-hr")) {
  match.arg(geo_level, choices = c("pt", "hr", "sub_hr", several.ok = FALSE))
  dir_path <- file.path("raw_data", "active_ts", region)
  dir.create(dir_path, showWarnings = FALSE)
  f_name <- paste0(paste(region, val, geo_level, "ts", sep = "_"), ".csv")
  quote_range <- dplyr::case_when(
    geo_level == "pt" ~ 3,
    geo_level == "hr" ~ 4,
    geo_level == "sub-hr" ~ 5
  )
  write.csv(
    d,
    file.path(dir_path, f_name),
    row.names = FALSE,
    na = "",
    quote = 1:quote_range
  )
}

# case data

## ab
Covid19CanadaDataProcess::process_dataset(
  uuid = "59da1de8-3b4e-429a-9e18-b67ba3834002",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["59da1de8-3b4e-429a-9e18-b67ba3834002"]]) %>%
  write_active("ab", "cases", "hr")

## bc
Covid19CanadaDataProcess::process_dataset(
  uuid = "ab6abe51-c9b1-4093-b625-93de1ddb6302",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["ab6abe51-c9b1-4093-b625-93de1ddb6302"]]) %>%
  write_active("bc", "cases", "hr")

## can
Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]) %>%
  write_active("can", "cases", "pt")

## nl
Covid19CanadaDataProcess::process_dataset(
  uuid = "b19daaca-6b32-47f5-944f-c69eebd63c07",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["b19daaca-6b32-47f5-944f-c69eebd63c07"]]) %>%
  write_active("nl", "cases", "pt")

## on
Covid19CanadaDataProcess::process_dataset(
  uuid = "73fffd44-fbad-4de8-8d32-00cc5ae180a6",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["73fffd44-fbad-4de8-8d32-00cc5ae180a6"]]) %>%
  write_active("on", "cases", "hr")

## qc
Covid19CanadaDataProcess::process_dataset(
  uuid = "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["3b93b663-4b3f-43b4-a23d-cbf6d149d2c5"]]) %>%
  write_active("qc", "cases", "hr")

## yt
Covid19CanadaDataProcess::process_dataset(
  uuid = "8eb9a22f-a2c0-4bdb-8f6c-ef8134901efe",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["8eb9a22f-a2c0-4bdb-8f6c-ef8134901efe"]]) %>%
  write_active("yt", "cases", "pt")

# death data

## can
Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "mortality",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]) %>%
  dplyr::mutate(name = "deaths") %>%
  write_active("can", "deaths", "pt")

## on
on1 <- Covid19CanadaDataProcess::process_dataset(
  uuid = "73fffd44-fbad-4de8-8d32-00cc5ae180a6",
  val = "mortality",
  fmt = "hr_ts",
  ds = ds[["73fffd44-fbad-4de8-8d32-00cc5ae180a6"]]) %>%
  dplyr::mutate(name = "deaths")
# fix obvious error
on1[on1$sub_region_1 == "TORONTO" &
      on1$date == as.Date("2021-02-02"), "value"] <- on1[
        on1$sub_region_1 == "TORONTO" &
          on1$date == as.Date("2021-02-01"), "value"]

write_active(on1, "on", "deaths", "hr")
rm(on1)

## qc
Covid19CanadaDataProcess::process_dataset(
  uuid = "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5",
  val = "mortality",
  fmt = "hr_ts",
  ds = ds[["3b93b663-4b3f-43b4-a23d-cbf6d149d2c5"]]) %>%
  dplyr::mutate(name = "deaths") %>%
  write_active("qc", "deaths", "hr")

# hospitalization data

## on
Covid19CanadaDataProcess::process_dataset(
  uuid = "4b214c24-8542-4d26-a850-b58fc4ef6a30",
  val = "hospitalizations",
  fmt = "prov_ts",
  ds = ds[["4b214c24-8542-4d26-a850-b58fc4ef6a30"]]) %>%
  write_active("on", "hospitalizations", "pt")

## qc
Covid19CanadaDataProcess::process_dataset(
  uuid = "f0c25e20-2a6c-4f9a-adc3-61b28ab97245",
  val = "hospitalizations",
  fmt = "prov_ts",
  ds = ds[["f0c25e20-2a6c-4f9a-adc3-61b28ab97245"]]) %>%
  date_shift(1) %>%
  write_active("qc", "hospitalizations", "pt")

# icu data

## on
Covid19CanadaDataProcess::process_dataset(
  uuid = "4b214c24-8542-4d26-a850-b58fc4ef6a30",
  val = "icu",
  fmt = "prov_ts",
  ds = ds[["4b214c24-8542-4d26-a850-b58fc4ef6a30"]]) %>%
  write_active("on", "icu", "pt")

## qc
Covid19CanadaDataProcess::process_dataset(
  uuid = "f0c25e20-2a6c-4f9a-adc3-61b28ab97245",
  val = "icu",
  fmt = "prov_ts",
  ds = ds[["f0c25e20-2a6c-4f9a-adc3-61b28ab97245"]]) %>%
  date_shift(1) %>%
  write_active("qc", "icu", "pt")

# testing data
Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "testing",
  fmt = "prov_ts",
  testing_type = "n_tests_completed",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]) %>%
  dplyr::mutate(name = "tests_completed") %>%
  write_active("can", "tests_completed", "pt")

# original CCODWG dataset

## cases
readr::read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_hr/cases_timeseries_hr.csv") %>%
  dplyr::transmute(
    region = .data$province,
    sub_region_1 = .data$health_region,
    date = as.Date(.data$date_report, "%d-%m-%Y"),
    value = .data$cumulative_cases
  ) %>%
  convert_pt_names() %>%
  tibble::add_column(name = "cases", .before = 1) %>%
  dplyr::mutate(sub_region_1 = ifelse(.data$sub_region_1 == "Not Reported", "Unknown", .data$sub_region_1)) %>%
  write.csv("raw_data/ccodwg/can_cases_hr_ts.csv", row.names = FALSE, quote = 1:4)

## deaths
readr::read_csv("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_hr/mortality_timeseries_hr.csv") %>%
  dplyr::transmute(
    region = .data$province,
    sub_region_1 = .data$health_region,
    date = as.Date(.data$date_death_report, "%d-%m-%Y"),
    value = .data$cumulative_deaths
  ) %>%
  convert_pt_names() %>%
  tibble::add_column(name = "deaths", .before = 1) %>%
  dplyr::mutate(sub_region_1 = ifelse(.data$sub_region_1 == "Not Reported", "Unknown", .data$sub_region_1)) %>%
  write.csv("raw_data/ccodwg/can_deaths_hr_ts.csv", row.names = FALSE, quote = 1:4)

# covid19tracker.ca dataset

## hospitalizations
lapply(pt, function(x) {
  url <- paste0("https://api.covid19tracker.ca/reports/province/", x, "?stat=hospitalizations&fill_dates=false")
  jsonlite::fromJSON(url)$data %>%
    dplyr::transmute(
      name = "hospitalizations",
      region = x,
      .data$date,
      value = .data$total_hospitalizations
    )
}) %>%
  dplyr::bind_rows() %>%
  write.csv("raw_data/covid19tracker/can_hospitalizations_pt_ts.csv", row.names = FALSE)

## icu
lapply(pt, function(x) {
  url <- paste0("https://api.covid19tracker.ca/reports/province/", x, "?stat=criticals&fill_dates=false")
  jsonlite::fromJSON(url)$data %>%
    dplyr::transmute(
      name = "icu",
      region = x,
      .data$date,
      value = .data$total_criticals
    )
}) %>%
  dplyr::bind_rows() %>%
  write.csv("raw_data/covid19tracker/can_icu_pt_ts.csv", row.names = FALSE)
