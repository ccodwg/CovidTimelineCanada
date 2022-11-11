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

# keep population estimates beginning Q1 2020
pop <- pop[which(pop$date == "2020-01")[1]:nrow(pop), ]

# join population data to pt
pt <- dplyr::left_join(
  pt,
  pop,
  by = c("name_canonical" = "region")
)

# long to wide
pt <- tidyr::pivot_wider(
  pt,
  names_from = date,
  names_prefix = "pop_",
  values_from = pop
)

# create "pop" column with most recent pop value
pop_recent <- pt[, ncol(pt), drop = TRUE]
pt <- tibble::add_column(pt, pop = pop_recent, .after = "name_ccodwg")

# replace hyphens in column names with underscores
names(pt) <- sub("-", "_", names(pt))

# save updated pt.csv
utils::write.csv(pt, "geo/pt.csv", row.names = FALSE)
