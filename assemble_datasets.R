# Assemble and process final COVID-19 datasets from various sources #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load pipe
library(magrittr)

# source functions
source("funs.R")

# case dataset

## ab
cases_ab <- read_d("raw_data/active_ts/ab/ab_cases_hr_ts.csv")

## bc
cases_bc <- read_d("raw_data/active_ts/bc/bc_cases_hr_ts.csv") %>%
  dplyr::filter(sub_region_1 != "Out of Canada")

## mb
cases_mb <- dplyr::bind_rows(
  read_d("raw_data/static/mb/mb_cases_hr_ts.csv") %>%
    date_shift(1),
  read_d("raw_data/reports/mb/mb_weekly_report.csv") %>%
    report_pluck("cases", "cumulative_cases", "value", "hr")
)

## nb
cases_nb <- dplyr::bind_rows(
  get_ccodwg_d("cases", "NB", to = "2021-03-07", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/static/nb/nb_cases_hr_ts.csv") %>%
    convert_hr_names(),
  read_d("raw_data/reports/nb/nb_weekly_report.csv") %>%
    report_pluck("cases", "cumulative_cases", "value", "hr") %>%
    convert_hr_names()
)

## nl
cases_nl <- dplyr::bind_rows(
  get_ccodwg_d("cases", "NL", to = "2021-03-15", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/static/nl/nl_cases_hr_ts.csv") %>%
    convert_hr_names(),
  read_d("raw_data/active_ts/nl/nl_cases_pt_ts.csv") %>%
    dplyr::filter(.data$date >= as.Date("2022-03-12")) %>%
    dplyr::transmute(
      name = .data$name,
      region = .data$region,
      sub_region_1 = "Unknown",
      date = .data$date,
      value = cumsum(value_daily))
  ) %>%
  convert_hr_names()

## ns
ns1 <- read_d("raw_data/static/ns/ns_cases_hr_ts_1.csv")
ns2 <- read_d("raw_data/static/ns/ns_cases_hr_ts_2.csv") %>%
  dplyr::filter(.data$date <= as.Date("2021-12-09"))
cases_ns <- append_daily_d(ns1, ns2)
ns3 <- read_d("raw_data/reports/ns/ns_daily_news_release.csv") %>%
  report_pluck("cases", "cases", "value_daily", "hr") %>%
  dplyr::mutate(sub_region_1 = sub("Zone \\d - ", "", .data$sub_region_1))
cases_ns <- append_daily_d(cases_ns, ns3)
ns4 <- read_d("raw_data/reports/ns/ns_weekly_report.csv") %>%
  report_pluck("cases", "cases", "value_daily", "pt") %>%
  pt_add_hr_col("Unknown")
cases_ns <- append_daily_d(cases_ns, ns4)
rm(ns1, ns2, ns3, ns4) # cleanup

## nt
cases_nt <- get_phac_d("cases", "NT") %>%
  pt_add_hr_col("Northwest Territories")

## nu
cases_nu <- get_phac_d("cases", "NU") %>%
  pt_add_hr_col("Nunavut")

## on
cases_on <- dplyr::bind_rows(
  get_ccodwg_d("cases", "ON", to = "2020-03-31", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/active_ts/on/on_cases_hr_ts.csv") %>%
    convert_hr_names()
)

## pe
cases_pe <- get_phac_d("cases", "PE") %>%
  pt_add_hr_col("Prince Edward Island")

## qc
cases_qc <- read_d("raw_data/active_ts/qc/qc_cases_hr_ts.csv") %>%
  dplyr::filter(.data$sub_region_1 != "Hors Qu\u00E9bec") %>%
  dplyr::mutate(
    sub_region_1 = ifelse(.data$sub_region_1 == "Inconnu", "Unknown", .data$sub_region_1)) %>%
  date_shift(1)

## sk
sk1 <- read_d("raw_data/static/sk/sk_cases_hr_ts.csv")
sk2 <- read_d("raw_data/reports/sk/sk_weekly_report.csv") %>%
  report_pluck("cases", "cases", "value_daily", "hr") %>%
  dplyr::filter(.data$date > as.Date("2022-02-06")) # overlaps with end of TS
cases_sk <- append_daily_d(sk1, sk2) %>%
  dplyr::mutate(
    sub_region_1 = ifelse(.data$sub_region_1 == "Not Assigned", "Unknown", .data$sub_region_1))
rm(sk1, sk2) # cleanup

## yt
cases_yt <- read_d("raw_data/active_ts/yt/yt_cases_pt_ts.csv") %>%
  pt_add_hr_col("Yukon")

## assemble and process final dataset
suppressWarnings(rm(cases_hr)) # if re-running manually
cases_hr <- assemble_datasets("cases") %>%
  convert_hr_names() %>%
  dataset_format("hr")

# death dataset

## ab
deaths_ab <- read_d("raw_data/active_cumul/ab/ab_deaths_hr_ts.csv")

## bc
deaths_bc <- read_d("raw_data/active_cumul/bc/bc_deaths_hr_ts.csv")

## mb
deaths_mb <- dplyr::bind_rows(
  read_d("raw_data/static/mb/mb_deaths_hr_ts.csv") %>%
    date_shift(1),
  read_d("raw_data/reports/mb/mb_weekly_report.csv") %>%
    report_pluck("deaths", "cumulative_deaths", "value", "hr")
)

## nb
deaths_nb <- dplyr::bind_rows(
  get_ccodwg_d("deaths", "NB", to = "2021-03-07", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/static/nb/nb_deaths_hr_ts.csv") %>%
    convert_hr_names(),
  read_d("raw_data/reports/nb/nb_weekly_report.csv") %>%
    report_pluck("deaths", "cumulative_deaths", "value", "hr") %>%
    convert_hr_names()
)

## nl
deaths_nl <- dplyr::bind_rows(
  get_ccodwg_d("deaths", "NL", to = "2021-03-15", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/static/nl/nl_deaths_hr_ts.csv") %>%
    convert_hr_names(),
  read_d("raw_data/active_cumul/nl/nl_deaths_hr_ts.csv")
)

## ns
ns1 <- get_ccodwg_d("deaths", "NS", to = "2021-01-18", drop_not_reported = TRUE)
ns2 <- read_d("raw_data/static/ns/ns_deaths_hr_ts.csv") %>%
  dplyr::filter(.data$date <= as.Date("2021-12-09")) %>%
  dplyr::mutate(sub_region_1 = sub("Zone \\d - ", "", .data$sub_region_1))
deaths_ns <- dplyr::bind_rows(ns1, ns2)
ns3 <- read_d("raw_data/reports/ns/ns_daily_news_release.csv") %>%
  report_pluck("deaths", "deaths", "value_daily", "hr") %>%
  dplyr::mutate(sub_region_1 = sub("Zone \\d - ", "", .data$sub_region_1))
deaths_ns <- append_daily_d(deaths_ns, ns3)
ns4 <- read_d("raw_data/reports/ns/ns_weekly_report.csv") %>%
  report_pluck("deaths", "deaths", "value_daily", "pt") %>%
  pt_add_hr_col("Unknown")
deaths_ns <- append_daily_d(deaths_ns, ns4)
rm(ns1, ns2, ns3, ns4) # cleanup

## nt
deaths_nt <- get_phac_d("deaths", "NT") %>%
  pt_add_hr_col("Northwest Territories")

## nu
deaths_nu <- get_phac_d("deaths", "NU") %>%
  pt_add_hr_col("Nunavut")

## on
deaths_on <- dplyr::bind_rows(
  get_ccodwg_d("deaths", "ON", to = "2020-03-31", drop_not_reported = TRUE) %>%
    convert_hr_names(),
  read_d("raw_data/active_ts/on/on_deaths_hr_ts.csv") %>%
    convert_hr_names()
)

## pe
deaths_pe <- get_phac_d("deaths", "PE") %>%
  pt_add_hr_col("Prince Edward Island")

## qc
deaths_qc <- read_d("raw_data/active_ts/qc/qc_deaths_hr_ts.csv") %>%
  dplyr::filter(.data$sub_region_1 != "Hors Qu\u00E9bec") %>%
  dplyr::mutate(
    sub_region_1 = ifelse(.data$sub_region_1 == "Inconnu", "Unknown", .data$sub_region_1)) %>%
  date_shift(1)

## sk
sk1 <- read_d("raw_data/static/sk/sk_deaths_hr_ts.csv") %>%
  dplyr::mutate(name = "deaths") %>% # may want to fix in source data
  dplyr::filter(.data$sub_region_1 != "Total") # may want to fix in source data
sk2 <- read_d("raw_data/reports/sk/sk_weekly_report.csv") %>%
  report_pluck("deaths", "deaths", "value_daily", "hr") %>%
  dplyr::filter(.data$date > as.Date("2022-02-06")) # overlaps with end of TS
deaths_sk <- append_daily_d(sk1, sk2) %>%
  dplyr::mutate(
    sub_region_1 = ifelse(.data$sub_region_1 == "Not Assigned", "Unknown", .data$sub_region_1))
rm(sk1, sk2) # cleanup

## yt
deaths_yt <- get_phac_d("deaths", "YT") %>%
  pt_add_hr_col("Yukon")

## assemble and process final dataset
suppressWarnings(rm(deaths_hr)) # if re-running manually
deaths_hr <- assemble_datasets("deaths") %>%
  convert_hr_names() %>%
  dataset_format("hr")

# hospitalizations dataset

## ab
hospitalizations_ab <- get_covid19tracker_d("hospitalizations", "AB")

## bc
hospitalizations_bc <- get_covid19tracker_d("hospitalizations", "BC")

## mb
hospitalizations_mb <- dplyr::bind_rows(
  get_covid19tracker_d("hospitalizations", "MB", to = "2021-02-03"),
  read_d("raw_data/static/mb/mb_hospitalizations_pt_ts.csv"),
  get_covid19tracker_d("hospitalizations", "MB", from = "2022-03-26")
)

## nb
hospitalizations_nb <- dplyr::bind_rows(
  get_covid19tracker_d("hospitalizations", "NB", to = "2021-03-07"),
  read_d("raw_data/static/nb/nb_hospitalizations_pt_ts_1.csv"),
  read_d("raw_data/static/nb/nb_hospitalizations_pt_ts_2.csv"),
  read_d("raw_data/reports/nb/nb_weekly_report.csv") %>%
    report_pluck("hospitalizations", "active_hospitalizations", "value", "pt")
)

## nl
hospitalizations_nl <- dplyr::bind_rows(
  read_d("raw_data/static/nl/nl_hospitalizations_pt_ts.csv"),
  get_covid19tracker_d("hospitalizations", "NL", from = "2022-03-12")
)

## ns
hospitalizations_ns <- dplyr::bind_rows(
  get_covid19tracker_d("hospitalizations", "NS", to = "2021-01-18"),
  read_d("raw_data/static/ns/ns_hospitalizations_pt_ts.csv"),
  get_covid19tracker_d("hospitalizations", "NS", from = "2022-01-19")
)

## nt
hospitalizations_nt <- get_covid19tracker_d("hospitalizations", "NT")

## nu
hospitalizations_nu <- get_covid19tracker_d("hospitalizations", "NU")

## on
hospitalizations_on <- read_d("raw_data/active_ts/on/on_hospitalizations_pt_ts.csv")

## pe
hospitalizations_pe <- get_covid19tracker_d("hospitalizations", "PE")

## qc
hospitalizations_qc <- read_d("raw_data/active_ts/qc/qc_hospitalizations_pt_ts.csv") %>%
  date_shift(1)

## sk
hospitalizations_sk <- dplyr::bind_rows(
  read_d("raw_data/static/sk/sk_hospitalizations_pt_ts.csv"),
  get_covid19tracker_d("hospitalizations", "SK", from = "2022-02-07")
)

## yt
hospitalizations_yt <- get_covid19tracker_d("hospitalizations", "YT")

## assemble and process final dataset
suppressWarnings(rm(hospitalizations_pt)) # if re-running manually
hospitalizations_pt <- assemble_datasets("hospitalizations") %>%
  dataset_format("pt")

# icu dataset

## ab
icu_ab <- get_covid19tracker_d("icu", "AB")

## bc
icu_bc <- get_covid19tracker_d("icu", "BC")

## mb
icu_mb <- dplyr::bind_rows(
  get_covid19tracker_d("icu", "MB", to = "2021-02-03"),
  read_d("raw_data/static/mb/mb_icu_pt_ts.csv"),
  get_covid19tracker_d("icu", "MB", from = "2022-03-26")
)

## nb
icu_nb <- dplyr::bind_rows(
  get_covid19tracker_d("icu", "NB", to = "2021-03-07"),
  read_d("raw_data/static/nb/nb_icu_pt_ts_1.csv"),
  read_d("raw_data/static/nb/nb_icu_pt_ts_2.csv"),
  read_d("raw_data/reports/nb/nb_weekly_report.csv") %>%
    report_pluck("icu", "active_icu", "value", "pt")
)

## nl
icu_nl <- dplyr::bind_rows(
  get_covid19tracker_d("icu", "NL", to = "2021-03-15"),
  read_d("raw_data/static/nl/nl_icu_pt_ts.csv"),
  get_covid19tracker_d("icu", "NL", from = "2022-03-12")
)

## ns
icu_ns <- dplyr::bind_rows(
  get_covid19tracker_d("icu", "NS", to = "2021-01-18"),
  read_d("raw_data/static/ns/ns_icu_pt_ts.csv"),
  get_covid19tracker_d("icu", "NS", from = "2022-01-19")
)

## nt
icu_nt <- get_covid19tracker_d("icu", "NT")

## nu
icu_nu <- get_covid19tracker_d("icu", "NU")

## on
icu_on <- read_d("raw_data/active_ts/on/on_icu_pt_ts.csv")

## pe
icu_pe <- get_covid19tracker_d("icu", "PE")

## qc
icu_qc <- read_d("raw_data/active_ts/qc/qc_icu_pt_ts.csv") %>%
  date_shift(1)

## sk
icu_sk <- dplyr::bind_rows(
  read_d("raw_data/static/sk/sk_icu_pt_ts.csv"),
  get_covid19tracker_d("icu", "SK", from = "2022-02-07")
)

## yt
icu_yt <- get_covid19tracker_d("icu", "YT")

## assemble and process final dataset
suppressWarnings(rm(icu_pt)) # if re-running manually
icu_pt <- assemble_datasets("icu") %>%
  dataset_format("pt")

# tests_completed dataset

## assemble and process final dataset
tests_completed_pt <- get_phac_d("tests_completed", "all") %>%
  dataset_format("pt")

# create aggregated datasets (HR -> PT)
cases_pt <- agg2pt(cases_hr)
deaths_pt <- agg2pt(deaths_hr)

# create aggregated datasets (PT -> CAN)
cases_can <- agg2can(cases_pt)
deaths_can <- agg2can(deaths_pt)
hospitalizations_can <- agg2can(hospitalizations_pt)
icu_can <- agg2can(icu_pt)
tests_completed_can <- agg2can(tests_completed_pt)

# write datasets
write_dataset(cases_hr, "hr", "cases_hr")
write_dataset(cases_pt, "pt", "cases_pt")
write_dataset(cases_can, "can", "cases_can")
write_dataset(deaths_hr, "hr", "deaths_hr")
write_dataset(deaths_pt, "pt", "deaths_pt")
write_dataset(deaths_can, "can", "deaths_can")
write_dataset(hospitalizations_pt, "pt", "hospitalizations_pt")
write_dataset(hospitalizations_can, "can", "hospitalizations_can")
write_dataset(icu_pt, "pt", "icu_pt")
write_dataset(icu_can, "can", "icu_can")
write_dataset(tests_completed_pt, "pt", "tests_completed_pt")
write_dataset(tests_completed_can, "can", "tests_completed_can")

# write update time
update_time <- lubridate::with_tz(Sys.time(), tzone = "America/Toronto") %>%
  format.Date("%Y-%m-%d %H:%M %Z")
cat(paste0(update_time, "\n"), file = "update_time.txt")
