# Extract BC time series data using RSelenium #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

### WEEKLY DATA ###

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

### TESTING TIME SERIES ###

# open dashboard with webdriver
remDr <- Covid19CanadaData::webdriver_open("https://bccdc.shinyapps.io/respiratory_covid_sitrep/#Test_rates_and_percent_positivity")
Sys.sleep(15) # wait 15 seconds for dashboard to load

# change time range from "Recent twelve months" to "All time"
remDr$findElement(using = "css selector", "div#section-test-rates-and-percent-positivity .selectize-control")$clickElement()
remDr$findElement(using = "css selector", "div#section-test-rates-and-percent-positivity .selectize-dropdown-content .option[data-value='all_time']")$clickElement()

# wait for chart to update
Sys.sleep(3)

# JavaScript to extract data from figure
js_script <- '
    var el = document.querySelectorAll("div#figure6 .trace.bars")[1];
    var data = el.__data__;
    var simplifiedData = data.map(function(d) {
        return {x: d.p, y: d.s1};
    });
    return simplifiedData;
'

# extract data
dat_testing <- remDr$executeScript(js_script)

# close webdriver
Covid19CanadaData::webdriver_close(remDr)

# format data
dat_testing <- dplyr::bind_rows(lapply(dat_testing, function(z) data.frame(x = z$x, y = z$y))) |>
  dplyr::transmute(
    date = date_local,
    source = "https://bccdc.shinyapps.io/respiratory_covid_sitrep/#Test_rates_and_percent_positivity",
    date_start = lubridate::date(as.POSIXct(x / 1000, origin = "1970-01-01", tz = "UTC")),
    date_end = date_start + 6,
    region = "BC",
    value = y)

# sync data to Google Sheets
googlesheets4::write_sheet(data = dat_testing, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "bc_monthly_report_testing")
