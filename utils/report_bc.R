# Extract BC time series data using RSelenium #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# load dashboard
ds <- Covid19CanadaData::dl_dataset("b85ca9d5-3a88-403d-9444-cac73ffb2d3f")

# extract and format weekly data table
tab <- rvest::html_table(rvest::html_element(ds, "#table1"), header = FALSE)
tab_names <- c("name", "date", as.character(tab[2, 3:7]), "Total")
tab_names <- dplyr::case_when(
  tab_names == "FH" ~ "Fraser Health",
  tab_names == "IH" ~ "Interior Health",
  tab_names == "NH" ~ "Northern Health",
  tab_names == "VCH" ~ "Vancouver Coastal Health",
  tab_names == "VIHA" ~ "Island Health",
  TRUE ~ tab_names
)
tab <- tab[-c(1, 2, nrow(tab)), ]
names(tab) <- tab_names
tab <- tab |>
  dplyr::mutate(name = ifelse(name == "", NA, name)) |>
  tidyr::fill(name, .direction = "down") |>
  tidyr::pivot_longer(
    cols = -c("name", "date"),
    names_to = "sub_region_1",
    values_to = "value"
  )

# parse dates
tab <- tab |>
  dplyr::mutate(
    date = gsub("-.*|\\.", "", date),
    date = as.Date(date, format = "%b %d"),
    date = as.Date(ifelse(date > date_local, date - lubridate::years(1), date), "1970-01-01") # ensure year is correct
  )

# format data
tab <- tab |>
  dplyr::transmute(
    name = dplyr::case_when(
      name == "Hospital admissions" ~ "new_hospitalizations",
      name == "Critical care admissions" ~ "new_icu",
      name == "Deaths" ~ "deaths",
      name == "Cases" ~ "cases"
    ),
    date_start = date,
    date_end = date + lubridate::days(6),
    region = "BC",
    sub_region_1 = ifelse(sub_region_1 == "Total", "", sub_region_1),
    value
  ) |>
  dplyr::arrange(name) |>
  tidyr::pivot_wider(
    names_from = name,
    values_from = value
  ) |>
  dplyr::arrange(date_start, sub_region_1) |>
  dplyr::mutate(dplyr::across(c("cases", "deaths", "new_hospitalizations", "new_icu"), as.integer))

# add date and source
tab <- tab |>
  dplyr::mutate(
    date = date_local,
    source = "https://bccdc.shinyapps.io/respiratory_covid_sitrep/",
    .before = 1)

# check weekly sums for province match health region totals
tab_hr <- tab |>
  dplyr::filter(sub_region_1 != "") |>
  dplyr::select(date_start, cases, deaths, new_hospitalizations, new_icu) |>
  dplyr::group_by(date_start) |>
  dplyr::summarize(dplyr::across(c("cases", "deaths", "new_hospitalizations", "new_icu"), sum), .groups = "drop")
tab_bc <- tab |>
  dplyr::filter(sub_region_1 == "") |>
  dplyr::select(date_start, cases, deaths, new_hospitalizations, new_icu)
identical(tab_hr, tab_bc) # should be TRUE

# append data
googlesheets4::sheet_append(data = tab, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "bc_monthly_report")
