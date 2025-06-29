# Update annual population values in geo/hr.csv #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load hr.csv and remove existing pop columns
hr <- utils::read.csv("geo/hr.csv") |>
  dplyr::select(
    !dplyr::starts_with("pop")
  )

# load annual population estimates from Statistics Canada (17-10-0157-01)
temp <- tempfile()
temp_dir <- tempdir()
download.file("https://www150.statcan.gc.ca/n1/en/tbl/csv/17100157-eng.zip", temp)
utils::unzip(temp, files = "17100157.csv", exdir = temp_dir)
pop <- utils::read.csv(file.path(temp_dir, "17100157.csv")) |>
  # keep total population numbers
  dplyr::filter(
    .data$Age.group == "Total, all ages" & .data$Gender == "Total - gender") |>
  # keep relevant columns
  dplyr::transmute(
    # remove peer group and other letters from HRUIDs
    hruid = sub("-.*$", "", .data$DGUID),
    hruid = sub("^[^0-9]+", "", .data$hruid), # Toronto (A3595)
    date = .data$REF_DATE,
    pop = .data$VALUE) |>
  # remove Saskatchewan data
  dplyr::filter(
    !grepl("^47", .data$hruid)
  )

# keep population estimates from 2019 to 2023
pop <- pop[pop$date %in% 2019:2023, ]

# update/combine health regions
pop$hruid <- ifelse(grepl("^59", pop$hruid), substr(pop$hruid, 1, 3), pop$hruid) # BC HSDAs to HAs
pop[pop$hruid == 3552, "hruid"] <- 3575 # Oxford -> Southwestern
pop[pop$hruid == 3554, "hruid"] <- 3539 # Perth and Huron amalgamation
pop[pop$hruid == 1020, "hruid"] <- 1011 # Eastern Urban + Rural amalgamation
pop[pop$hruid == 1021, "hruid"] <- 1011 # Eastern Urban + Rural amalgamation
pop[pop$hruid == 1022, "hruid"] <- 1012 # Central
pop[pop$hruid == 1023, "hruid"] <- 1013 # Western
pop[pop$hruid == 1024, "hruid"] <- 1014 # Labrador-Grenfell

# filter to health regions in hr.csv
pop <- dplyr::filter(pop, .data$hruid %in% as.character(hr$hruid))

# aggregate population for combined health regions
pop <- pop |>
  dplyr::group_by(.data$hruid, .data$date) |>
  dplyr::summarize(pop = sum(.data$pop), .groups = "drop")

# update columns
pop <- pop |>
  dplyr::mutate(
    # hruid to integer for joining back to hr
    hruid = as.integer(.data$hruid),
    # population estimates are mid-year estimates
    date = paste0(.data$date, "_07")
)

# long to wide
pop <- tidyr::pivot_wider(
  pop,
  names_from = date,
  names_prefix = "pop_",
  values_from = pop
)

# create "pop" column with most recent pop value
pop_recent <- pop[, ncol(pop), drop = TRUE]
pop <- tibble::add_column(pop, pop = pop_recent, .before = "pop_2019_07")

# join population data to hr
hr <- dplyr::left_join(
  hr,
  pop,
  by = c("hruid")
)

# download and process SK population data
sk_pop_2020 <- jsonlite::read_json("https://web.archive.org/web/20201006213033/https://dashboard.saskatchewan.ca/api/health/subgeography/summary", simplifyVector = TRUE)$subgeographies
sk_pop_2020$name <- trimws(sub("\\d", "", sk_pop_2020$name)) # aggregate 32 sub-zones to 13 zones
sk_pop_2020 <- sk_pop_2020 |>
  dplyr::select(c("name", "population")) |>
  dplyr::group_by(.data$name) |>
  dplyr::summarize(pop_2020_07 = sum(.data$population))
sk_pop_2021 <- jsonlite::read_json("https://web.archive.org/web/20210717040047/https://dashboard.saskatchewan.ca/api/health/subgeography/summary", simplifyVector = TRUE)$subgeographies
sk_pop_2021$name <- trimws(sub("\\d", "", sk_pop_2021$name)) # aggregate 32 sub-zones to 13 zones
sk_pop_2021 <- sk_pop_2021 |>
  dplyr::select(c("name", "population")) |>
  dplyr::group_by(.data$name) |>
  dplyr::summarize(pop_2021_07 = sum(.data$population))
sk_pop <- dplyr::left_join(sk_pop_2020, sk_pop_2021, by = "name") |>
  dplyr::mutate(
    pop = .data$pop_2021_07 # use most recent population
  )

# add SK data to hr
idx_sk <- match(sk_pop$name, hr$name_canonical)
valid_sk <- !is.na(idx_sk)
hr[["pop_2020_07"]][idx_sk[valid_sk]] <- sk_pop[["pop_2020_07"]][valid_sk]
hr[["pop_2021_07"]][idx_sk[valid_sk]] <- sk_pop[["pop_2021_07"]][valid_sk]
hr[["pop"]][idx_sk[valid_sk]] <- sk_pop[["pop"]][valid_sk]

# test that population data is available for all HRs in the map files
for (f in c("geo/hr.geojson", "geo/hr_wgs84.geojson")) {
  sf::read_sf(f) |>
    dplyr::mutate(hruid = as.integer(.data$hruid)) |>
    dplyr::left_join(hr, by = "hruid") |>
    dplyr::filter(is.na(pop)) |>
    dplyr::pull(hruid) |>
    {\(x) if (length(x) > 0) stop(paste("Population data missing for HRs:", paste(x, collapse = ", ")))}()
}

# write data
utils::write.csv(hr, "geo/hr.csv", row.names = FALSE, na = "")
