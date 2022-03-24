# load packages
library(dplyr)
library(Covid19CanadaData)
library(Covid19CanadaDataProcess)
library(Covid19CanadaETL)
library(jsonlite)

# define provinces
provs <- c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT")

# download datasets

## list datasets
covid_datasets <- list(
  # ab
  "59da1de8-3b4e-429a-9e18-b67ba3834002",
  # bc
  "ab6abe51-c9b1-4093-b625-93de1ddb6302",
  # can
  "f7db31d0-6504-4a55-86f7-608664517bdb",
  # mb
  # nb
  # nl
  # ns
  # nt
  # nu
  # on
  "73fffd44-fbad-4de8-8d32-00cc5ae180a6",
  "4b214c24-8542-4d26-a850-b58fc4ef6a30",
  # pe
  # qc
  "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5",
  "f0c25e20-2a6c-4f9a-adc3-61b28ab97245"
  # sk
  # yt
)

## read in datasets
ds <- lapply(covid_datasets, FUN = function(x) {
  d <- Covid19CanadaData::dl_dataset(x)
  cat(x, fill = TRUE)
  return(d)}
)

## name datasets according to UUID
names(ds) <- covid_datasets

# load case data

## AB
ab_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "59da1de8-3b4e-429a-9e18-b67ba3834002",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["59da1de8-3b4e-429a-9e18-b67ba3834002"]]
) %>% process_hr_names("AB")

## BC
bc_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "ab6abe51-c9b1-4093-b625-93de1ddb6302",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["ab6abe51-c9b1-4093-b625-93de1ddb6302"]]
) %>% process_hr_names("BC")

## NT
nt_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "NT") %>% process_prov2hr("NT")

## NU
nu_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "NU") %>% process_prov2hr("NU")

## ON
on_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "73fffd44-fbad-4de8-8d32-00cc5ae180a6",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["73fffd44-fbad-4de8-8d32-00cc5ae180a6"]]
) %>% process_hr_names("ON", opt = "moh") %>%
  dplyr::filter(.data$sub_region_1 != "Not Reported")
on_cases_hr <- on_cases_hr[!duplicated(on_cases_hr), ] # stopgap fix
on_cases_hr_ccodwg <- Covid19CanadaData::dl_ccodwg(type = "timeseries", stat = "cases", loc = "hr") %>%
  dplyr::filter(province == "Ontario") %>%
  dplyr::rename(
    sub_region_1 = .data$health_region,
    date = .data$date_report,
    value = .data$cumulative_cases,
  ) %>%
  dplyr::mutate(
    name = "cases",
    province = "ON",
    date = as.Date(.data$date)) %>%
  dplyr::select(.data$name, .data$province, .data$sub_region_1, .data$date, .data$value) %>%
  dplyr::filter(.data$date < as.Date("2020-04-01") & .data$sub_region_1 != "Not Reported") %>%
  dplyr::arrange(.data$date, .data$sub_region_1)
on_cases_hr <- dplyr::bind_rows(on_cases_hr_ccodwg, on_cases_hr)

## PE
pe_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "PE") %>% process_prov2hr("PE")

## QC
qc_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5",
  val = "cases",
  fmt = "hr_ts",
  ds = ds[["3b93b663-4b3f-43b4-a23d-cbf6d149d2c5"]]
) %>%
  dplyr::mutate(
    sub_region_1 = dplyr::case_when(
      .data$sub_region_1 == "Gaspésie-Îles-de-la-Madeleine" ~ "Gasp\u00E9sie - \u00CEles-de-la-Madeleine",
      .data$sub_region_1 == "Saguenay-Lac-Saint-Jean" ~ "Saguenay - Lac-Saint-Jean",
      TRUE ~ .data$sub_region_1
    )
  ) %>%
  process_hr_names("QC") %>%
  dplyr::group_by(dplyr::across(c(-.data$value))) %>%
  dplyr::summarize(value = sum(.data$value), .groups = "drop")

## YT
yt_cases_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "cases",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "YT") %>% process_prov2hr("YT")

## Other provinces
cases_hr <- Covid19CanadaData::dl_ccodwg(type = "timeseries", stat = "cases", loc = "hr") %>%
  dplyr::mutate(
    name = "cases",
    province = dplyr::case_when(
      .data$province == "Alberta" ~ "AB",
      .data$province == "BC" ~ "BC",
      .data$province == "Manitoba" ~ "MB",
      .data$province == "New Brunswick" ~ "NB",
      .data$province == "NL" ~ "NL",
      .data$province == "Nova Scotia" ~ "NS",
      .data$province == "Saskatchewan" ~ "SK",
      TRUE ~ .data$province
    ),
    date_report = as.Date(.data$date_report)) %>%
  dplyr::filter(.data$province %in% c("MB", "NB", "NL", "NS", "SK")) %>%
  dplyr::select(
    .data$name, .data$province, .data$health_region, .data$date_report, .data$cumulative_cases) %>%
  dplyr::rename(
    sub_region_1 = .data$health_region,
    date = .data$date_report,
    value = .data$cumulative_cases
  )

## join it all together
cases_hr <- dplyr::bind_rows(
  cases_hr, ab_cases_hr, bc_cases_hr, nt_cases_hr, nu_cases_hr, on_cases_hr, pe_cases_hr, qc_cases_hr, yt_cases_hr
) %>%
  dplyr::arrange(.data$province, .data$date, .data$sub_region_1)

# load mortality data

## NT
nt_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "mortality",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "NT") %>% process_prov2hr("NT")

## NU
nu_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "mortality",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "NU") %>% process_prov2hr("NU")

## ON
# ontario time series is zeroed out for deaths on April 1, so start on April 2
on_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "73fffd44-fbad-4de8-8d32-00cc5ae180a6",
  val = "mortality",
  fmt = "hr_ts",
  ds = ds[["73fffd44-fbad-4de8-8d32-00cc5ae180a6"]]
) %>% process_hr_names("ON", opt = "moh") %>%
  dplyr::filter(.data$sub_region_1 != "Not Reported" & .data$date >= as.Date("2020-04-02"))
on_mortality_hr <- on_mortality_hr[!duplicated(on_mortality_hr), ] # stopgap fix
on_mortality_hr_ccodwg <- Covid19CanadaData::dl_ccodwg(type = "timeseries", stat = "mortality", loc = "hr") %>%
  dplyr::filter(province == "Ontario") %>%
  dplyr::rename(
    sub_region_1 = .data$health_region,
    date = .data$date_death_report,
    value = .data$cumulative_deaths,
  ) %>%
  dplyr::mutate(
    name = "mortality",
    province = "ON",
    date = as.Date(.data$date)) %>%
  dplyr::select(.data$name, .data$province, .data$sub_region_1, .data$date, .data$value) %>%
  dplyr::filter(.data$date < as.Date("2020-04-02") & .data$sub_region_1 != "Not Reported") %>%
  dplyr::arrange(.data$date, .data$sub_region_1)
on_mortality_hr <- dplyr::bind_rows(on_mortality_hr_ccodwg, on_mortality_hr)

## PE
pe_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "mortality",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "PE") %>% process_prov2hr("PE")

## QC
qc_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "3b93b663-4b3f-43b4-a23d-cbf6d149d2c5",
  val = "mortality",
  fmt = "hr_ts",
  ds = ds[["3b93b663-4b3f-43b4-a23d-cbf6d149d2c5"]]
) %>%
  dplyr::mutate(
    sub_region_1 = dplyr::case_when(
      .data$sub_region_1 == "Gaspésie-Îles-de-la-Madeleine" ~ "Gasp\u00E9sie - \u00CEles-de-la-Madeleine",
      .data$sub_region_1 == "Saguenay-Lac-Saint-Jean" ~ "Saguenay - Lac-Saint-Jean",
      TRUE ~ .data$sub_region_1
    )
  ) %>%
  process_hr_names("QC") %>%
  dplyr::group_by(dplyr::across(c(-.data$value))) %>%
  dplyr::summarize(value = sum(.data$value), .groups = "drop")

## YT
yt_mortality_hr <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "mortality",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]]
) %>% dplyr::filter(province == "YT") %>% process_prov2hr("YT")

## Other provinces
mortality_hr <- Covid19CanadaData::dl_ccodwg(type = "timeseries", stat = "mortality", loc = "hr") %>%
  dplyr::mutate(
    name = "mortality",
    province = dplyr::case_when(
      .data$province == "Alberta" ~ "AB",
      .data$province == "BC" ~ "BC",
      .data$province == "Manitoba" ~ "MB",
      .data$province == "New Brunswick" ~ "NB",
      .data$province == "NL" ~ "NL",
      .data$province == "Nova Scotia" ~ "NS",
      .data$province == "Saskatchewan" ~ "SK",
      TRUE ~ .data$province
    ),
    date_death_report = as.Date(.data$date_death_report)) %>%
  dplyr::filter(.data$province %in% c("AB", "BC", "MB", "NB", "NL", "NS", "SK")) %>%
  dplyr::select(
    .data$name, .data$province, .data$health_region, .data$date_death_report, .data$cumulative_deaths) %>%
  dplyr::rename(
    sub_region_1 = .data$health_region,
    date = .data$date_death_report,
    value = .data$cumulative_deaths
  )

## join it all together
mortality_hr <- dplyr::bind_rows(
  mortality_hr, nt_mortality_hr, nu_mortality_hr, on_mortality_hr, pe_mortality_hr, qc_mortality_hr, yt_mortality_hr
) %>%
  dplyr::arrange(.data$province, .data$date, .data$sub_region_1)

# postprocessing
datasets <- c("cases_hr", "mortality_hr")

## calculate daily diffs
for (d in datasets) {
  assign(d, get(d) %>%
           dplyr::group_by(.data$province, .data$sub_region_1) %>%
           dplyr::mutate(value_daily = c(first(value), diff(value))) %>%
           dplyr::ungroup())
}

## create province-level datasets
for (d in datasets) {
  assign(sub("_hr", "_prov", d), get(d) %>%
           dplyr::select(-.data$sub_region_1) %>%
           dplyr::group_by(.data$province, .data$date) %>%
           dplyr::summarize(
             value = sum(.data$value),
             value_daily = sum(.data$value_daily),
             .groups = "drop"
           ))
}

## write datasets
for (d in c(datasets, sub("_hr", "_prov", datasets))) {
  write.csv(get(d), file = paste0("data/", d, ".csv"), row.names = FALSE)
}

# testing data
tests_completed_prov <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f7db31d0-6504-4a55-86f7-608664517bdb",
  val = "testing",
  fmt = "prov_ts",
  ds = ds[["f7db31d0-6504-4a55-86f7-608664517bdb"]],
  testing_type = "n_tests_completed"
) %>%
  dplyr::mutate(
    name = "tests completed") %>%
  dplyr::filter(!.data$province %in% c("CAN", "RT")) %>%
  dplyr::group_by(.data$province) %>%
  dplyr::mutate(value_daily = c(first(value), diff(value))) %>%
  dplyr::ungroup()

## write data
write.csv(tests_completed_prov, file = "data/tests_completed_prov.csv", row.names = FALSE)

# load hospitalization data

## ON
on_hosp_prov <- Covid19CanadaDataProcess::process_dataset(
  uuid = "4b214c24-8542-4d26-a850-b58fc4ef6a30",
  val = "hospitalizations",
  fmt = "prov_ts",
  ds = ds[["4b214c24-8542-4d26-a850-b58fc4ef6a30"]]
)

## QC
qc_hosp_prov <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f0c25e20-2a6c-4f9a-adc3-61b28ab97245",
  val = "hospitalizations",
  fmt = "prov_ts",
  ds = ds[["f0c25e20-2a6c-4f9a-adc3-61b28ab97245"]]
)

## Other provinces
hosp_prov <- lapply(provs[!provs %in% c("ON", "NT", "NU", "YT")], function(x) {
  url <- paste0("https://api.covid19tracker.ca/reports/province/", tolower(x), "?stat=hospitalizations")
  jsonlite::fromJSON(url)$data %>%
    dplyr::mutate(
      province = x,
      date = as.Date(.data$date)) %>%
    dplyr::rename(
      value = .data$total_hospitalizations
    ) %>%
    dplyr::select(.data$province, .data$date, .data$value) %>%
    Covid19CanadaDataProcess:::helper_ts(
      loc = "prov", val = "hospitalizations", prov = x, convert_to_cum = FALSE)
}) %>%
  dplyr::bind_rows() %>%
  dplyr::filter(!(.data$province == "QC" & .data$date >= as.Date("2020-04-10"))) # beginning of official data

## join it all together
hosp_prov <- dplyr::bind_rows(
  hosp_prov, on_hosp_prov, qc_hosp_prov
) %>%
  dplyr::arrange(.data$province, .data$date) %>%
  dplyr::group_by(.data$province) %>%
  dplyr::mutate(value_daily = c(first(value), diff(value))) %>%
  dplyr::ungroup()

# load icu data

## ON
on_icu_prov <- Covid19CanadaDataProcess::process_dataset(
  uuid = "4b214c24-8542-4d26-a850-b58fc4ef6a30",
  val = "icu",
  fmt = "prov_ts",
  ds = ds[["4b214c24-8542-4d26-a850-b58fc4ef6a30"]]
)

## QC
qc_icu_prov <- Covid19CanadaDataProcess::process_dataset(
  uuid = "f0c25e20-2a6c-4f9a-adc3-61b28ab97245",
  val = "icu",
  fmt = "prov_ts",
  ds = ds[["f0c25e20-2a6c-4f9a-adc3-61b28ab97245"]]
)

## Other provinces
icu_prov <- lapply(provs[!provs %in% c("ON", "NT", "NU", "YT")], function(x) {
  url <- paste0("https://api.covid19tracker.ca/reports/province/", tolower(x), "?stat=criticals")
  jsonlite::fromJSON(url)$data %>%
    dplyr::mutate(
      province = x,
      date = as.Date(.data$date)) %>%
    dplyr::rename(
      value = .data$total_criticals
    ) %>%
    dplyr::select(.data$province, .data$date, .data$value) %>%
    Covid19CanadaDataProcess:::helper_ts(
      loc = "prov", val = "icu", prov = x, convert_to_cum = FALSE)
}) %>%
  dplyr::bind_rows() %>%
  dplyr::filter(!(.data$province == "QC" & .data$date >= as.Date("2020-04-10"))) # beginning of official data

## join it all together
icu_prov <- dplyr::bind_rows(
  icu_prov, on_icu_prov, qc_icu_prov
) %>%
  dplyr::arrange(.data$province, .data$date) %>%
  dplyr::group_by(.data$province) %>%
  dplyr::mutate(value_daily = c(first(value), diff(value))) %>%
  dplyr::ungroup()

# postprocessing
datasets <- c("hosp_prov", "icu_prov")

## calculate daily diffs
for (d in datasets) {
  assign(d, get(d) %>%
           dplyr::group_by(.data$province) %>%
           dplyr::mutate(value_daily = c(first(value), diff(value))) %>%
           dplyr::ungroup())
}

## write datasets
for (d in datasets) {
  write.csv(get(d), file = paste0("data/", d, ".csv"), row.names = FALSE)
}
