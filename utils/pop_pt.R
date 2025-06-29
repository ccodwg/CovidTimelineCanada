# Update quarterly population values in geo/pt.csv #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# load pt.csv and remove existing pop columns
pt <- utils::read.csv("geo/pt.csv") |>
  dplyr::select(
    "region",
    "pruid",
    "name_canonical",
    "name_canonical_fr",
    "name_ccodwg")

# load quarterly population estimates from Statistics Canada (17-10-0009-01)
temp <- tempfile()
temp_dir <- tempdir()
download.file("https://www150.statcan.gc.ca/n1/tbl/csv/17100009-eng.zip", temp)
utils::unzip(temp, files = "17100009.csv", exdir = temp_dir)
pop <- utils::read.csv(file.path(temp_dir, "17100009.csv")) |>
  dplyr::transmute(
    region = .data$GEO,
    date = .data$REF_DATE,
    pop = .data$VALUE)

# keep population estimates beginning Q1 2020 and ending Q4 2023
pop <- pop[pop$date %in%
             apply(expand.grid(2020:2023, c("01", "04", "07", "10")),
                   1, paste, collapse = "-"), ]

# long to wide
pop <- tidyr::pivot_wider(
  pop,
  names_from = date,
  names_prefix = "pop_",
  values_from = pop
)

# replace hyphens in column names with underscores
names(pop) <- sub("-", "_", names(pop))

# create "pop" column with most recent pop value
pop_recent <- pop[, ncol(pop), drop = TRUE]
pop <- tibble::add_column(pop, pop = pop_recent, .before = "pop_2020_01")

# join population data to pt
pt <- dplyr::left_join(
  pt,
  pop,
  by = c("name_canonical" = "region")
)

# test that population data is available for all PTs in the map files
for (f in c("geo/pt.geojson", "geo/pt_wgs84.geojson")) {
  sf::read_sf(f) |>
    dplyr::mutate(pruid = as.integer(.data$pruid)) |>
    dplyr::left_join(pt, by = "pruid") |>
    dplyr::filter(is.na(pop)) |>
    dplyr::pull(pruid) |>
    {\(x) if (length(x) > 0) stop(paste("Population data missing for PTs:", paste(x, collapse = ", ")))}()
}

# save updated pt.csv
utils::write.csv(pt, "geo/pt.csv", row.names = FALSE, na = "")
