# Update Nova Scotia Respiratory Watch data in Google Sheets #
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

req = get_legacy_session(CustomHttpAdapter).get('https://novascotia.ca/dhw/cdpc/respiratory-watch.asp', timeout=5)
url_current = 'https://novascotia.ca/dhw/cdpc/' + BeautifulSoup(req.content).find('a', text=re.compile('^Respiratory Watch Week'))['href']

session = get_legacy_session(CustomHttpAdapter)
with session.get(url_current, stream=True) as response:
    with open('%s', 'wb') as file:
        for chunk in response.iter_content(chunk_size=8192):
            file.write(chunk)
", ds))

# extract tables
tab <- camelot$read_pdf(ds, pages = "5,7")
tab_cases <- lapply(seq_along(tab) - 1, function(i) tab[i]$df)[[1]]
tab_outcomes <- lapply(seq_along(tab) - 1, function(i) tab[i]$df)[[2]]

# function: pad vector w/ NAs
pad_na <- function(x, n) {
  c(x, rep(NA, times = n))
}

# construct output table
# hosp admission/ICU admission/death:
# In this table, only the most severe outcome for a case is included; numbers of hospitalizations and ICU admissions
# could therefore decline over time, if a person counted in one of those columns moves to a more severe outcome.
out <- dplyr::tibble(
  date = date_today,
  source = url$url_current,
  date_start = "", # manual
  date_end = "", # manual
  region = "NS",
  sub_region_1 = c("", "1201", "1202", "1203", "1204"),
  cases = NA,
  cases_period	= as.integer(tab_cases[c(6, 2:5), 2]),
  `cumulative_cases_since_2023-08-27` = as.integer(tab_cases[c(6, 2:5), 3]),
  `cumulative_cases_since_2023-08-27_diff` = NA,
  deaths = NA,
  `cumulative_deaths_since_2023-08-27` = pad_na(as.integer(tab_outcomes[8, 4]), 4),
  `cumulative_deaths_since_2023-08-27_diff` = NA,
  hosp_admissions = NA,
  `cumulative_hosp_admissions_since_2023-08-27`	= pad_na(as.integer(tab_outcomes[8, 2]) + as.integer(tab_outcomes[8, 3]), 4), # non-ICU + ICU
  `cumulative_hosp_admissions_since_2023-08-27_diff` = NA,
  icu_admissions = NA,
  `cumulative_icu_admissions_since_2023-08-27` = pad_na(as.integer(tab_outcomes[8, 3]), 4),
  `cumulative_icu_admissions_since_2023-08-27_diff` = NA,
  notes = NA
)

# append data
googlesheets4::sheet_append(data = out, ss = "1ZTUb3fVzi6CLZAbU3lj6T6FTzl5Aq-arBNL49ru3VLo", sheet = "ns_respiratory_watch_report")
