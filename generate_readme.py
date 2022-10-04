# load modules
import importlib
import pandas as pd

# check for tabulate module (required for df.to_markdown())
check_tabulate = importlib.util.find_spec("tabulate")
if check_tabulate is None:
    raise ImportError("The 'tabulate' module is required for df.to_markdown().")

# load data_sources.csv
d = pd.read_csv(
    "data_sources.csv",
    dtype = str,
    usecols = ["value_name", "region", "source_name", "date_begin", "date_end"])

# function: generate table for specific value
def gen_table(d, val, title):
    # filter to specific value
    d = d[d["value_name"] == val]
    d = d.drop("value_name", axis = 1)
    # create entries
    d["data_sources"] = "- " + d["source_name"] + " (" + d["date_begin"] + "\u2013" + d["date_end"] + ")"
    # drop unnecessary columns
    d = d.drop(["source_name", "date_begin", "date_end"], axis = 1)
    # join entries for each region
    d = d.groupby(["region"])["data_sources"].apply("<br>".join).reset_index()
    # convert to markdown table
    d = d.rename(columns = {"region": "P/T", "data_sources": "Data sources"})
    d = d.to_markdown(index = False)
    # fortify table with <details> tags
    d = "<details>\n<summary><b>" + title + "</b></summary>\n\n" + d + "\n</details>"
    # return table
    return d

# cases
t_cases = gen_table(d, "cases", "Cases")

# deaths
t_deaths = gen_table(d, "deaths", "Deaths")

# hospitalizations
t_hospitalizations = gen_table(d, "hospitalizations", "Hospitalizations")

# icu
t_icu = gen_table(d, "icu", "ICU")

# tests_completed
t_tests_completed = gen_table(d, "tests_completed", "Tests completed")

# vaccine_coverage
t_vaccine_coverage = (
    "<details>\n<summary><b>Vaccine coverage</b></summary>\n\n"
    "All data on COVID-19 vaccine coverage are from the [Public Health Agency of Canada vaccination coverage page](https://health-infobase.canada.ca/covid-19/vaccination-coverage/)."
    "\n</details>"
)


# vaccine_administration
t_vaccine_administration = (
    "<details>\n<summary><b>Vaccine administration</b></summary>\n\n"
    "All data on COVID-19 vaccine administration are from the [Public Health Agency of Canada vaccination coverage page](https://health-infobase.canada.ca/covid-19/vaccination-coverage/)."
    "\n</details>"
)

# vaccine_distribution
t_vaccine_distribution = (
    "<details>\n<summary><b>Vaccine distribution</b></summary>\n\n"
    "**Coming soon!**"
    "\n</details>"
)

# assemble "data sources" section of README
data_sources = "\n\n".join(
    [t_cases, t_deaths, t_hospitalizations, t_icu, t_tests_completed, t_vaccine_coverage, t_vaccine_administration, t_vaccine_distribution]
)

# load README content
with open("docs/README_content.md", "r") as f:
    readme = f.read()

# substitute data sources section
readme = readme.replace("<!-- data sources -->", data_sources)

# write README
with open("README.md", "w") as f:
    f.write(readme)
