# Update Nova Scotia monthly epidemiologic summary data in Google Sheets #
# Author: Jean-Paul R. Soucy #

# Note: This script assumes the working directory is set to the root directory of the project.
# This is most easily achieved by using the provided CovidTimelineCanada.Rproj in RStudio.

# make sure the Python package "Camelot" is installed along with all dependencies
# also ensure that Python code can be run with the "reticulate" R package
# https://camelot-py.readthedocs.io/en/master/user/install.html
# https://rstudio.github.io/reticulate/

# authorize with Google Sheets
googlesheets4::gs4_auth()

# get today's date
date_today <- lubridate::date(lubridate::with_tz(Sys.time(), "America/Toronto"))

# import camelot
camelot <- reticulate::import("camelot")

# load report
ds <- file.path(tempdir(), "ns_report_temp.pdf")
url <- reticulate::py_run_string(sprintf("
import requests
from bs4 import BeautifulSoup
import re

class CustomHttpAdapter(requests.adapters.HTTPAdapter):
    def __init__(self, ssl_context=None, **kwargs):
        self.ssl_context = ssl_context
        super().__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        import urllib3
        self.poolmanager = urllib3.poolmanager.PoolManager(
            num_pools=connections, maxsize=maxsize,
            block=block, ssl_context=self.ssl_context)

def get_legacy_session(custom_session):
    import ssl
    ctx = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
    ctx.options |= 0x4
    session = requests.session()
    session.mount('https://', custom_session(ctx))
    return session

req = get_legacy_session(CustomHttpAdapter).get('https://novascotia.ca/coronavirus/alerts-notices/', timeout=5)
url_current = re.sub('^\\.\\.', 'https://novascotia.ca/coronavirus', BeautifulSoup(req.content).find('a', text=re.compile('^COVID-19 Epidemiologic Summary'))['href'])

session = get_legacy_session(CustomHttpAdapter)
with session.get(url_current, stream=True) as response:
    with open('%s', 'wb') as file:
        for chunk in response.iter_content(chunk_size=8192):
            file.write(chunk)
", ds))

# extract table
tab <- camelot$read_pdf(ds, pages = "6", flavor = "lattice")
tab <- lapply(seq_along(tab) - 1, function(i) tab[i]$df)[[1]]
names(tab) <- gsub("\n", "", tab[1, ]) # fix column names
tab <- tab[-1, ]
tab[2, 2] <- readr::parse_number(tab[2, 1]) # fix extraction of hospitalizations number in second column

# construct output table
out <- dplyr::tibble(
  date = date_today,
  source = url$url_current,
  date_start = lubridate::floor_date(date_today, unit = "month") - months(1), # first day of month
  date_end = lubridate::ceiling_date(date_today, unit = "month") - 1 - months(1), # last day of month
  region = "NS",
  sub_region_1 = NA,
  cases = NA,
  cases_monthly	= as.integer(tab[1, 2]),
  cases_monthly_previous = as.integer(tab[1, 3]),
  `cumulative_cases_since_2022-07-01` = as.integer(tab[1, 5]),
  `cumulative_cases_since_2022-07-01_diff` = NA,
  deaths = NA,
  deaths_monthly = as.integer(tab[3, 2]),
  deaths_monthly_previous = as.integer(tab[3, 3]),
  `cumulative_deaths_since_2022-07-01` = as.integer(tab[3, 5]),
  `cumulative_deaths_since_2022-07-01_diff` = NA,
  new_hospitlizations	= NA,
  new_hospitalizations_monthly = as.integer(tab[2, 2]),
  new_hospitalizations_monthly_previous = as.integer(tab[2, 3]),
  `new_hospitalizations_since_2022-07-01` = as.integer(tab[2, 5]),
  `new_hospitalizations_since_2022-07-01_diff` = NA,
  notes = NA
)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "ns_monthly_report")
