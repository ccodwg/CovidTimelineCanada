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

# define provinces/territories with single health region versus multiple health regions
pt_one = ['NT', 'NU', 'PE', 'YT']
pt_mult = ['AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'ON', 'QC', 'SK']

# load data_sources.csv and filter to cases and deaths
d = pd.read_csv(
    os.path.join(script_dir, "data_sources.csv"),
    dtype = str,
    usecols = ["value_name", "region", "geo", "date_end"])
d = d[d["value_name"].isin(["cases", "deaths"])]

### CASE DATA ###

# filter to case data
d_cases = d[d["value_name"] == "cases"]

# filter to regions that now report cases at the PT level
d_cases_pt = d_cases.groupby("region").last().reset_index()
d_cases_pt = d_cases_pt[d_cases_pt["geo"] == "province_territory"]["region"]
d_cases = d_cases[d_cases["region"].isin(d_cases_pt)]

# for provinces/territories with single health region,
# filter to those where most recent date_end is not "present"
d_cases_one = d_cases[d_cases["region"].isin(pt_one)].groupby(["value_name", "region"])["date_end"].max().reset_index()
d_cases_one = d_cases_one[d_cases_one["date_end"] != "present"].drop("value_name", axis = 1)

# for provinces/territories with multiple health regions,
# filter to most recent date for health region-level reporting
d_cases_mult = d_cases[(d_cases["region"].isin(pt_mult)) & (d_cases["geo"] == "health_region")].groupby(["value_name", "region"])["date_end"].max().reset_index().drop("value_name", axis = 1)

### DEATH DATA ###

# filter to death data
d_deaths = d[d["value_name"] == "deaths"]

# filter to regions that now report deaths at the PT level
d_deaths_pt = d_deaths.groupby("region").last().reset_index()
d_deaths_pt = d_deaths_pt[d_deaths_pt["geo"] == "province_territory"]["region"]
d_deaths = d_deaths[d_deaths["region"].isin(d_deaths_pt)]

# for provinces/territories with single health region,
# filter to those where most recent date_end is not "present"
d_deaths_one = d_deaths[d_deaths["region"].isin(pt_one)].groupby(["value_name", "region"])["date_end"].max().reset_index()
d_deaths_one = d_deaths_one[d_deaths_one["date_end"] != "present"].drop("value_name", axis = 1)

# for provinces/territories with multiple health regions,
# filter to most recent date for health region-level reporting
d_deaths_mult = d_deaths[(d_deaths["region"].isin(pt_mult)) & (d_deaths["geo"] == "health_region")].groupby(["value_name", "region"])["date_end"].max().reset_index().drop("value_name", axis = 1)

# function: generate table for specific value
def gen_table(d_one, d_mult, title):
    # generate rows for provinces/territories with single health region
    t_one = pd.DataFrame({"region": pt_one})
    t_one = pd.merge(t_one, d_one, on = "region", how = "left")
    t_one["status"] = t_one.apply(lambda x: "Still reporting (single HR)" if pd.isna(x["date_end"]) else "Ended reporting completely", axis = 1)
    # generate rows for province/territories with multiple health regions
    t_mult = pd.DataFrame({"region": pt_mult})
    t_mult = pd.merge(t_mult, d_mult, on = "region", how = "left")
    t_mult["status"] = t_mult.apply(lambda x: "Still reporting at HR level" if pd.isna(x["date_end"]) else "Ended reporting at HR level", axis = 1)
    # combine and sort
    t = pd.concat([t_one, t_mult]).sort_values("region")
    t["date_end"] = t["date_end"].fillna("")
    # convert to markdown table
    t = t.reindex(columns = ["region", "status", "date_end"]).rename(columns = {"region": "P/T", "status": "HR-level reporting status", "date_end": "Date reporting ended"})
    t = t.to_markdown(index = False)
    # add title
    t = "### " + title + "\n\n" + t
    # return table
    return t

# cases
t_cases = gen_table(d_cases_one, d_cases_mult, "Cases")

# deaths
t_deaths = gen_table(d_deaths_one, d_deaths_mult, "Deaths")

# assemble document
doc = "\n\n".join(
    [t_cases, t_deaths]
)

# add header
doc = "## Health region-level data reporting\n\n" + doc

# write document
with open(os.path.join(script_dir, "hr_reporting.md"), "w") as f:
    f.write(doc)
