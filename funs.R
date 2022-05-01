# Functions for: CovidTimelineCanada #

# define constants
pt <- c(
  "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT")

# read in dataset
read_d <- function(file) {
  # define column types
  cols <- readr::cols(
    name = readr::col_character(),
    region = readr::col_character(),
    sub_region_1 = readr::col_character(),
    sub_region_2 = readr::col_character(),
    date = readr::col_date("%Y-%m-%d"),
    value = readr::col_integer(),
    value_daily = readr::col_integer()
  )
  # read dataset
  readr::read_csv(
    file = file,
    col_types = cols) %>%
    suppressWarnings() # suppress warnings about unused column names
}

# shift dates by x days
date_shift <- function(d, n_days) {
  d %>%
    dplyr::mutate(date = date + n_days)
}

# format combined dataset
dataset_format <- function(d, geo = c("pt", "hr", "sub-hr")) {
  match.arg(geo, c("pt", "hr", "sub-hr"), several.ok = FALSE)
  # expand dates and regions
  out <- split(d, d$region) # ensure separate date ranges for each region
  switch(
    geo,
    "pt" = {
      col_names <- c("name", "region", "date")
      out <- lapply(out, function(x) {
        tidyr::expand(
          x,
          tidyr::nesting(name, region),
          date = seq.Date(min(x$date), max(x$date), by = "day"))
      }) %>% dplyr::bind_rows()
    },
    "hr" = {
      col_names <- c("name", "region", "date", "sub_region_1")
      out <- lapply(out, function(x) {
        tidyr::expand(
          x,
          tidyr::nesting(name, region, sub_region_1),
          date = seq.Date(min(x$date), max(x$date), by = "day"))
      }) %>% dplyr::bind_rows()
    },
    "sub-hr" = {
      col_names <- c("name", "region", "date", "sub_region_1", "sub_region_2")
      out <- lapply(out, function(x) {
        tidyr::expand(
          x,
          tidyr::nesting(name, region, sub_region_1, sub_region_2),
          date = seq.Date(min(x$date), max(x$date), by = "day"))
      }) %>% dplyr::bind_rows()
    }
  )
  # join and format data
  out <- dplyr::right_join(d, out, by = col_names) %>%
    # dplyr::arrange(!!!rlang::syms(col_names)[col_names != "date"]) %>%
    # fill missing values
    dplyr::group_by(dplyr::across(c(-date, -value))) %>%
    dplyr::arrange(.data$date) %>%
    tidyr::fill(.data$value, .direction = "down") %>%
    tidyr::replace_na(list(value = 0)) %>%
    # calculate daily differences
    dplyr::mutate(value_daily = c(dplyr::first(.data$value), diff(.data$value))) %>%
    dplyr::ungroup() %>%
    # final sort
    dplyr::arrange(!!!rlang::syms(col_names))
  # check for duplicate observations
  dedup <- dplyr::distinct(out, dplyr::across(c(-value, -value_daily)))
  if (nrow(out) != nrow(dedup)) {
    print(
      dplyr::count(out, dplyr::across(c(-value, -value_daily))) %>%
        dplyr::filter(.data$n > 1))
    stop("Observations are not unique: check for data overlaps")
  }
  # return data
  out
}

# pluck relevant data from weekly reports
report_pluck <- function(d, name, val, out_col, geo) {
  match.arg(geo, c("pt", "hr"), several.ok = FALSE)
  # filter data
  if (geo == "pt") {
    d <- d %>%
      dplyr::filter(is.na(.data$sub_region_1)) %>%
      dplyr::transmute(
        name = name,
        .data$region,
        date = .data$date_end,
        "{out_col}" := !!rlang::sym(val)
      )
  } else {
    d <- d %>%
      dplyr::filter(!is.na(.data$sub_region_1)) %>%
      dplyr::transmute(
        name = name,
        .data$region,
        .data$sub_region_1,
        date = .data$date_end,
        "{out_col}" := !!rlang::sym(val)
      )
  }
  # return data
  d %>% dplyr::filter(!is.na(!!rlang::sym(out_col)))
}

# append a daily value dataset to a cumulative value dataset
append_daily_d <- function(d1, d2) {
  d2 <- d2 %>%
    dplyr::group_by(.data$name, .data$region, .data$sub_region_1) %>%
    dplyr::transmute(
      .data$name,
      .data$region,
      .data$sub_region_1,
      .data$date,
      value = cumsum(value_daily)) %>%
    dplyr::ungroup()
  d1_h <- unique(d1$sub_region_1)
  for (h in unique(d2$sub_region_1)) {
    # check for incompatible sub_region_1 names
    if (!h %in% d1_h) {
      # special case for "Unknown" sub_region_1 in d2, which may be missing from d1
      if (h == "Unknown") {
        break
      } else {
        stop("Sub-region names are incompatible")
      }
    } else {
      # convert daily values in d2 to cumulative values based on final cumulative value in d1
      d2[d2$sub_region_1 == h, "value"] <- d2[d2$sub_region_1 == h, "value"] +
        d1[d1$sub_region_1 == h & d1$date == max(d1$date), "value", drop = TRUE]
    }
  }
  # returned combined dataset
  dplyr::bind_rows(d1, d2)
}

# assemble datasets
assemble_datasets <- function(val) {
  dplyr::bind_rows(
    mget(ls(.GlobalEnv, pattern = paste0(val, "_(", paste(tolower(pt), collapse = "|"), ")")), envir = .GlobalEnv)
  )
}

# fortify a PT-level dataset with a health region column
pt_add_hr_col <- function(d, name) {
  d %>% tibble::add_column(sub_region_1 = name, .after = "region")
}

# get PHAC data for a particular value and region
get_phac_d <- function(val, region) {
  match.arg(val, c("cases", "deaths", "tests_completed"))
  # get relevant value
  d <- switch(
    val,
    "cases" = {read_d("raw_data/active_ts/can/can_cases_pt_ts.csv")},
    "deaths" = {read_d("raw_data/active_ts/can/can_deaths_pt_ts.csv")},
    "tests_completed" = {read_d("raw_data/active_ts/can/can_tests_completed_pt_ts.csv")}
  )
  # filter to region
  if (region == "all") {
    d[d$region != "CAN", ]
  } else {
    d[d$region == region, ]
  }
}

# get CCODWG data for a particular value and region
get_ccodwg_d <- function(val, region, from = NULL, to = NULL, drop_not_reported = FALSE) {
  match.arg(val, c("cases", "deaths"))
  # get relevant value
  d <- switch(
    val,
    "cases" = {read_d("raw_data/ccodwg/can_cases_hr_ts.csv")},
    "deaths" = {read_d("raw_data/ccodwg/can_deaths_hr_ts.csv")}
  )
  # filter to region
  d <- d[d$region == region, ]
  # date filter
  if (!is.null(from)) {
    d <- d[d$date >= as.Date(from), ]
  }
  if (!is.null(to)) {
    d <- d[d$date <= as.Date(to), ]
  }
  # drop "Not Reported"
  if (drop_not_reported) {
    d <- d[d$sub_region_1 != "Unknown", ] # we converted the name earlier
  }
  # return data
  d
}

# get covid19tracker.ca data for a particular value and region
get_covid19tracker_d <- function(val, region, from = NULL, to = NULL) {
  match.arg(val, c("hospitalizations", "icu"))
  # get relevant value
  d <- switch(
    val,
    "hospitalizations" = {read_d("raw_data/covid19tracker/can_hospitalizations_pt_ts.csv")},
    "icu" = {read_d("raw_data/covid19tracker/can_icu_pt_ts.csv")}
  )
  # filter to region
  d <- d[d$region == region, ]
  # date filter
  if (!is.null(from)) {
    d <- d[d$date >= as.Date(from), ]
  }
  if (!is.null(to)) {
    d <- d[d$date <= as.Date(to), ]
  }
  # return data
  d
}


# convert province/territory names to two-letter abbreviations
convert_pt_names <- function(d) {
  # CCODWG region names
  pt_convert <- c(
    "Alberta" = "AB",
    "BC" = "BC",
    "Manitoba" = "MB",
    "New Brunswick" = "NB",
    "NL" = "NL",
    "Nova Scotia" = "NS",
    "Nunavut" = "NU",
    "NWT" = "NT",
    "Ontario" = "ON",
    "PEI" = "PE",
    "Quebec" = "QC",
    "Saskatchewan" = "SK",
    "Yukon" = "YT",
    "Repatriated" = "Repatriated"
  )
  d[, "region"] <- dplyr::recode(d$region, !!!as.list(pt_convert))
  # return data frame with converted region column
  d
}

# convert health region names to HRUIDs
convert_hr_names <- function(d) {
  # read and process health region file
  hr <- readr::read_csv(
    "geo/health_regions.csv",
    col_types = "cccccccc") %>%
    dplyr::mutate(name_hruid = .data$hruid) %>%
    tidyr::pivot_longer(
      dplyr::starts_with("name_"),
      names_to = "hr_name"
    ) %>%
    dplyr::transmute(
      .data$region,
      sub_region_1 = .data$value,
      .data$hruid) %>%
    dplyr::filter(!is.na(.data$sub_region_1)) %>%
    dplyr::distinct()
  # convert health region names
  d <- d %>%
    dplyr::left_join(hr, by = c("region", "sub_region_1")) %>%
    dplyr::mutate(
      sub_region_1_original = .data$sub_region_1,
      sub_region_1 = ifelse(
        .data$sub_region_1 %in% c("Unknown", "9999"), "9999", .data$hruid)) %>%
    dplyr::arrange(.data$region, .data$sub_region_1)
  # check for conversion failures
  failed <- d[is.na(d$sub_region_1), "sub_region_1_original", drop = TRUE] %>%
    unique()
  if (length(failed) > 0) {
    stop(paste0("Some health region names failed to convert: ", paste(failed, collapse = ", ")))
  }
  # return converted data frame
  dplyr::select(d, -.data$sub_region_1_original, -.data$hruid)
}

# aggregate HR data up to PT
agg2pt <- function(d) {
  d %>%
    dplyr::select(-.data$sub_region_1) %>%
    dplyr::group_by(.data$name, .data$region, .data$date) %>%
    dplyr::summarise(value = sum(.data$value), value_daily = sum(.data$value_daily), .groups = "drop")
}

# aggregate PT data up to CAN
agg2can <- function(d) {
  d %>%
    dplyr::mutate(region = "CAN") %>%
    dplyr::group_by(.data$name, .data$region, .data$date) %>%
    dplyr::summarise(value = sum(.data$value), value_daily = sum(.data$value_daily), .groups = "drop")
}

# write dataset
write_dataset <- function(d, geo, name) {
  write.csv(
    d,
    file.path("data", geo, paste0(name, ".csv")),
    row.names = FALSE,
    quote = 1:(ncol(d) - 2))
}
