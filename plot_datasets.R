# load packages
library(ggplot2)
library(ggpubr)

# load data
files <- list.files("data", pattern = "*.csv", full.names = TRUE)
list2env(lapply(setNames(files, make.names(sub("*.csv$", "", basename(files)))),
                FUN = function(x) read.csv(x, colClasses = c("date" = "Date"))),
         envir = .GlobalEnv)

# plot function
plot_value <- function(data, type = c("daily", "cumulative"), title,
                       hr = FALSE, hide_negative_values = FALSE, facet_by_pt = FALSE) {
  match.arg(type, choices = c("daily", "cumulative"), several.ok = FALSE)
  if (type == "daily") {y <- "value_daily"} else {y <- "value"}
  if (hr) {
    p <- ggplot(data = data, aes(x = date, y = !!sym(y), colour = region,
                            group = paste(region, sub_region_1))) +
      geom_line(alpha = 0.3) +
      theme_pubclean() +
      labs(title = title) +
      theme(plot.title = element_text(hjust = 0.5)) +
      guides(colour = guide_legend(override.aes = list(alpha = 1)))
  } else {
    p <- ggplot(data = data, aes(x = date, y = !!sym(y), colour = region, group = region)) +
      geom_line() +
      theme_pubclean() +
      labs(title = title) +
      theme(plot.title = element_text(hjust = 0.5))
  }
  # hide negative values
  if (hide_negative_values) {
    p <- p + ylim(0, NA)
  }
  # facet by PT
  if (facet_by_pt) {
    p <- p + facet_wrap(~region)
  }
  # return plot
  p
}

# generate plots

## cases
plot_value(cases_pt, type = "daily", title = "Daily case data", hide_negative_values = TRUE)
ggsave("plots/cases_pt.png", width = 731, height = 603, units = "px", dpi = 96)
plot_value(cases_hr, type = "daily", title = "Daily case data (health regions)", hr = TRUE, hide_negative_values = TRUE)
ggsave("plots/cases_hr.png", width = 731, height = 603, units = "px", dpi = 96)

## mortality
plot_value(deaths_pt, type = "daily", title = "Daily death data", hide_negative_values = TRUE)
ggsave("plots/deaths_pt.png", width = 731, height = 603, units = "px", dpi = 96)
plot_value(deaths_hr, type = "daily", title = "Daily death data (health regions)", hr = TRUE, hide_negative_values = TRUE)
ggsave("plots/deaths_hr.png", width = 731, height = 603, units = "px", dpi = 96)

## testing
plot_value(tests_completed_pt, type = "daily", title = "Daily tests completed")
ggsave("plots/tests_completed_pt.png", width = 731, height = 603, units = "px", dpi = 96)

## hospitalizations
plot_value(hospitalizations_pt, type = "cumulative", title = "Hospitalization data")
ggsave("plots/hospitalizations_pt.png", width = 731, height = 603, units = "px", dpi = 96)

## icu
plot_value(icu_pt, type = "cumulative", title = "ICU data")
ggsave("plots/icu_pt.png", width = 731, height = 603, units = "px", dpi = 96)
