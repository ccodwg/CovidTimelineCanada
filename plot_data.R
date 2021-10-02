# load packages
library(ggplot2)
library(ggpubr)

# load data
files <- list.files("data", pattern = "*.csv", full.names = TRUE)
list2env(lapply(setNames(files, make.names(sub("*.csv$", "", basename(files)))),
                FUN = function(x) read.csv(x, colClasses = c("date" = "Date"))),
         envir = .GlobalEnv)

# plot function
plot_prov <- function(data, type = c("daily", "cumulative"), title) {
  match.arg(type, choices = c("daily", "cumulative"), several.ok = FALSE)
  if (type == "daily") {y <- "value_daily"} else {y <- "value"}
  ggplot(data = data, aes(x = date, y = !!sym(y), colour = province, group = province)) +
    geom_line() +
    theme_pubclean() +
    labs(title = title) +
    theme(plot.title = element_text(hjust = 0.5))
}

# generate plots

## cases
plot_prov(cases_prov, type = "daily", title = "Daily case data")

## mortality
plot_prov(mortality_prov, type = "daily", title = "Daily mortality data")

## testing
plot_prov(tests_completed_prov, type = "daily", title = "Daily tests completed")

## hospitalization
plot_prov(hosp_prov, type = "cumulative", title = "Hospitalization data")

## ICU
plot_prov(icu_prov, type = "cumulative", title = "ICU data")
