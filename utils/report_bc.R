# Extract BC time series data using RSelenium #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_local <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

### WEEKLY DATA ###

# open dashboard with webdriver
remDr <- Covid19CanadaData::webdriver_open("https://bccdc.shinyapps.io/respiratory_covid_sitrep/")
Sys.sleep(15) # wait 15 seconds for dashboard to load

# select "Currently in hospital" tab
remDr$findElement(using = "css selector", "a[data-value='Currently in hospital']")$clickElement()

# wait for chart to update
Sys.sleep(3)

# get page source
ds <- rvest::read_html(remDr$getPageSource()[[1]])

# close webdriver
Covid19CanadaData::webdriver_close(remDr)

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

# extract date of hospitalization data
hosp_date <- rvest::html_element(ds, "#curr_hosp_dt") |>
  rvest::html_text2() |>
  as.Date(format = "%B %d, %Y")

# add hospitalization and ICU data
tab_hosp <- rvest::html_table(rvest::html_element(ds, "#table3"), header = FALSE)
tab_hosp_names <- c("name", as.character(tab_hosp[2, 2:8]))
tab_hosp_names <- dplyr::case_when(
  tab_hosp_names == "FH" ~ "Fraser Health",
  tab_hosp_names == "IH" ~ "Interior Health",
  tab_hosp_names == "NH" ~ "Northern Health",
  tab_hosp_names == "PHSA" ~ "Provincial Health Services Authority",
  tab_hosp_names == "VCH" ~ "Vancouver Coastal Health",
  tab_hosp_names == "VIHA" ~ "Island Health",
  TRUE ~ tab_hosp_names
)
names(tab_hosp) <- tab_hosp_names
tab_hosp <- tab_hosp[3:4, ]
tab_hosp[, "name"] <- c("active_hospitalizations", "active_icu")
tab_hosp <- data.frame(t(tab_hosp))
names(tab_hosp) <- as.character(tab_hosp[1, ])
col_1 <- row.names(tab_hosp)[2:8]
col_1[col_1 == "Total"] <- ""
tab_hosp <- tab_hosp[-1, ]
tab_hosp <- tab_hosp |>
  dplyr::mutate(dplyr::across(dplyr::everything(), function(x) readr::parse_number(gsub(",", "", x))))
tab_hosp <- tab_hosp |>
  dplyr::transmute(
    date_start = hosp_date,
    date_end = hosp_date,
    region = "BC",
    sub_region_1 = col_1,
    .data$active_hospitalizations,
    .data$active_icu) |>
  dplyr::arrange(.data$sub_region_1)

# combine data
tab <- dplyr::bind_rows(tab, tab_hosp)

# add date and source
tab <- tab |>
  dplyr::mutate(
    date = date_local,
    source = "https://bccdc.shinyapps.io/respiratory_covid_sitrep/",
    .before = 1)

# check weekly sums for province match health region totals
tab_hr <- tab |>
  dplyr::filter(sub_region_1 != "") |>
  dplyr::select(date_start, cases, deaths, new_hospitalizations, new_icu, active_hospitalizations, active_icu) |>
  dplyr::group_by(date_start) |>
  dplyr::summarize(dplyr::across(c("cases", "deaths", "new_hospitalizations", "new_icu", "active_hospitalizations", "active_icu"),
                                 sum), .groups = "drop")
tab_bc <- tab |>
  dplyr::filter(sub_region_1 == "") |>
  dplyr::select(date_start, cases, deaths, new_hospitalizations, new_icu, active_hospitalizations, active_icu)
identical(tab_hr, tab_bc) # should be TRUE

# append data
googlesheets4::sheet_append(data = tab, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "bc_monthly_report")

### TESTING TIME SERIES ###

# open dashboard with webdriver
remDr <- Covid19CanadaData::webdriver_open("https://bccdc.shinyapps.io/respiratory_covid_sitrep/")
Sys.sleep(15) # wait 15 seconds for dashboard to load

# change time range from "Recent twelve months" to "All time"
remDr$findElement(using = "css selector", "div .section_topic5 .selectize-control")$clickElement()
remDr$findElement(using = "css selector", "div .section_topic5 .selectize-dropdown-content .option[data-value='all_time']")$clickElement()

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
    source = "",
    date_start = lubridate::date(as.POSIXct(x / 1000, origin = "1970-01-01", tz = "UTC")),
    date_end = date_start + 6,
    region = "BC",
    sub_region_1 = "",
    tests_completed_weekly = y)

# add source for first entry
dat_testing[1, "source"] <- "https://bccdc.shinyapps.io/respiratory_covid_sitrep/#Test_rates_and_percent_positivity"

# sync data to Google Sheets
googlesheets4::write_sheet(data = dat_testing, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "bc_monthly_report_testing")

### CUMULATIVE CASES, DEATHS, HOSPITAL ADMISSIONS, ICU ADMISSIONS BY HEALTH AUTHORITY ###

# open dashboard with webdriver
remDr <- Covid19CanadaData::webdriver_open("https://bccdc.shinyapps.io/respiratory_covid_sitrep/")
Sys.sleep(15) # wait 15 seconds for dashboard to load

# change tab from "Weekly totals" to "Historical totals"
remDr$findElement(using = "css selector", "a[data-value='Historical totals']")$clickElement()

# wait for tab to update
Sys.sleep(3)

# function: extract cumulative table
extract_cum_tab <- function(date_current) {
  # get table
  tab <- remDr$findElement(using = "css selector", "#table2 table")$getElementAttribute("outerHTML")[[1]] |>
    rvest::read_html() |>
    rvest::html_table(header = FALSE) |>
    (\(x) x[[1]])()
  # create and process data frame
  tab_names <- c("name", "notes", as.character(tab[2, 3:9]))
  tab_names <- dplyr::case_when(
    tab_names == "FH" ~ "Fraser Health",
    tab_names == "IH" ~ "Interior Health",
    tab_names == "NH" ~ "Northern Health",
    tab_names == "VCH" ~ "Vancouver Coastal Health",
    tab_names == "VIHA" ~ "Island Health",
    tab_names == "OOC" ~ "Out of Canada",
    TRUE ~ tab_names)
  names(tab) <- tab_names
  tab <- tab[3:7, -2]
  tab[, "name"] <- c("hosp_admissions", "icu_admissions", "deaths_up_to_2022-03-31", "deaths_after_2022-04-01", "cases")
  tab <- data.frame(t(tab))
  names(tab) <- as.character(tab[1, 1:5])
  col_1 <- row.names(tab)[2:8]
  col_1[col_1 == "Total"] <- ""
  tab <- tab[-1, ]
  tab <- tab |>
    dplyr::mutate(dplyr::across(dplyr::everything(), function(x) readr::parse_number(gsub(",", "", x))))
  tab |>
    dplyr::transmute(
      date = date_local,
      source = "",
      date_start = date_start,
      date_end = date_current,
      region = "BC",
      sub_region_1 = col_1,
      .data$cases,
      .data$`deaths_up_to_2022-03-31`,
      .data$`deaths_after_2022-04-01`,
      .data$hosp_admissions,
      .data$icu_admissions) |>
    dplyr::arrange(.data$sub_region_1)
}

# function: update "to" value for date slider
# http://ionden.com/a/plugins/ion.rangeslider/demo_interactions.html
update_date <- function(date_current) {
  d <- as.numeric(as.POSIXct(date_current, tz = "UTC")) * 1000
  remDr$executeScript(sprintf("var $d = $('#DatesMerge').data('ionRangeSlider'); $d.update({to: %s});", d))
}

# function: check if table div has class "recalculating"
check_recalculating <- function() {
  div_classes <- remDr$findElement(using = "css selector", "#table2")$getElementAttribute("class")[[1]]
  "recalculating" %in% strsplit(div_classes, " ")
}

# get date range
date_start <- remDr$findElement(using = "css selector", "div[data-value='Historical totals'] span.irs-min")$getElementAttribute("innerHTML")[[1]]
date_end <- remDr$findElement(using = "css selector", "div[data-value='Historical totals'] span.irs-max")$getElementAttribute("innerHTML")[[1]]

# get epoch values for all dates between date_start and date_end
dates <- seq.Date(from = as.Date(date_start), to = as.Date(date_end), by = "day")

# initialize list
dat_cum <- list()

# loop through dates
for (x in 1:length(dates)) {
  d <- dates[x]
  cat(as.character(d), fill = TRUE)
  # update date slider
  update_date(d)
  # wait for table to update
  Sys.sleep(3)
  # extract table
  dat_cum[[as.character(d)]] <- extract_cum_tab(d)
}

# close webdriver
Covid19CanadaData::webdriver_close(remDr)

# format data frame
dat_cum <- dplyr::bind_rows(dat_cum)

# add combined deaths column
dat_cum <- dat_cum |>
  dplyr::mutate(
    deaths = .data$`deaths_up_to_2022-03-31` + .data$`deaths_after_2022-04-01`, .after = .data$`deaths_after_2022-04-01`)

# add source for first entry
dat_cum[1, "source"] <- "https://bccdc.shinyapps.io/respiratory_covid_sitrep/"

# sync data to Google Sheets
googlesheets4::write_sheet(data = dat_cum, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "bc_monthly_report_cumulative")
