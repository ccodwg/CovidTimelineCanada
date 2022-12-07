# Update annual population values in geo/hr.csv #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load hr.csv and remove existing pop columns
hr <- utils::read.csv("geo/hr.csv") |>
  dplyr::select(
    !dplyr::starts_with("pop")
  )

# load annual population estimates from Statistics Canada (17-10-0134-01)
temp <- tempfile()
temp_dir <- tempdir()
download.file("https://www150.statcan.gc.ca/n1/en/tbl/csv/17100134-eng.zip", temp)
utils::unzip(temp, files = "17100134.csv", exdir = temp_dir)
pop <- utils::read.csv(file.path(temp_dir, "17100134.csv")) |>
  # keep total population numbers
  dplyr::filter(
    .data$Age.group == "Total, all ages" & .data$Sex == "Both sexes") |>
  # keep relevant columns
  dplyr::transmute(
    # remove peer group from HRUIDs
    hruid = sub("-.*$", "", .data$DGUID),
    date = .data$REF_DATE,
    pop = .data$VALUE) |>
  # remove Saskatchewan data
  dplyr::filter(
    !grepl("^47", .data$hruid)
  )

# keep population estimates beginning 2019
pop <- pop[which(pop$date == "2019")[1]:nrow(pop), ]

# update/combine health regions
pop$hruid <- ifelse(grepl("^59", pop$hruid), substr(pop$hruid, 1, 3), pop$hruid) # BC HSDAs to HAs
pop[pop$hruid == 3552, "hruid"] <- 3575 # Oxford -> Southwestern
pop[pop$hruid == 3554, "hruid"] <- 3539 # Perth and Huron amalgamation

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

# add SK population data
sk_pop <- jsonlite::read_json("https://dashboard.saskatchewan.ca/api/health/subgeography/summary", simplifyVector = TRUE)$subgeographies
sk_pop$name <- trimws(sub("\\d", "", sk_pop$name)) # aggregate 32 sub-zones to 13 zones
sk_pop <- sk_pop |>
  dplyr::select(c("name", "population")) |>
  dplyr::group_by(.data$name) |>
  dplyr::summarize(population = sum(.data$population))
hr <- dplyr::left_join(hr, sk_pop, by = c("name_canonical" = "name"))
hr <- hr |>
  dplyr::mutate(pop = ifelse(is.na(.data$population), .data$pop, .data$population)) |>
  dplyr::select(-"population")

# write data
utils::write.csv(hr, "geo/hr.csv", row.names = FALSE, na = "")
