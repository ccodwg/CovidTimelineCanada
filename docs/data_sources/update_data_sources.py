# load modules
import os
import importlib
import pandas as pd

# check for tabulate module (required for df.to_markdown())
check_tabulate = importlib.util.find_spec("tabulate")
if check_tabulate is None:
    raise ImportError("The 'tabulate' module is required for df.to_markdown().")

# get directory of this script
script_dir = os.path.dirname(os.path.abspath(__file__))

# load data_sources.csv
d = pd.read_csv(
    os.path.join(script_dir, "data_sources.csv"),
    dtype = str,
    usecols = ["value_name", "region", "source_name", "date_begin", "date_end", "pt_replacement", "not_available"])

# function: generate table for specific value
def gen_table(d, val, title):
    # filter to specific value
    d = d[d["value_name"] == val]
    d = d.drop("value_name", axis = 1)
    # create entries, noting those marked as not available
    d["data_sources"] = d.apply(lambda x: "Not available" if not pd.isna(x["not_available"]) else x["source_name"] + " (" + x["date_begin"] + "\u2013" + x["date_end"] + ")", axis = 1)
    # for health region-level data, note when province-level data have been replaced
    if val in ["cases", "deaths"]:
        d["data_sources"] = d.apply(lambda x: x["data_sources"] if pd.isna(x["pt_replacement"]) else "Province-level data: " + x["data_sources"], axis = 1)
    # drop unnecessary columns
    d = d.drop(["source_name", "date_begin", "date_end", "not_available", "pt_replacement"], axis = 1)
    # add bullets to entries
    d["data_sources"] = d["data_sources"].apply(lambda x: "- " + x)
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

# hosp_admissions
t_hosp_admissions = gen_table(d, "hosp_admissions", "Hospital admissions")

# icu_admissions
t_icu_admissions = gen_table(d, "icu_admissions", "ICU admissions")

# tests_completed
t_tests_completed = gen_table(d, "tests_completed", "Tests completed")

# vaccine_coverage
t_vaccine_coverage = gen_table(d, "vaccine_coverage", "Vaccine coverage")


# vaccine_administration
t_vaccine_administration = gen_table(d, "vaccine_administration", "Vaccine administration")

# vaccine_distribution
t_vaccine_distribution = gen_table(d, "vaccine_distribution", "Vaccine distribution")

# assemble document
data_sources = "\n\n".join(
    [t_cases, t_deaths, t_hospitalizations, t_icu, t_hosp_admissions, t_icu_admissions, t_tests_completed, t_vaccine_coverage, t_vaccine_administration, t_vaccine_distribution]
)

# add header
doc = "## Detailed description of data sources\n\n" + data_sources

# write document
with open(os.path.join(script_dir, "data_sources.md"), "w") as f:
    f.write(doc)
