# Timeline of COVID-19 in Canada

The purpose of this repository is to collaborate on assembling a definitive dataset for COVID-19 in Canada.

⚠️ Beginning April 30, this dataset replaced the original **[Covid19Canada](https://github.com/ccodwg/Covid19Canada)** dataset.

⚠️ Note that **province/territory (PT) names are now given using two-letter codes and health region (HR) names are given using unique identifiers**. See the [geo](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory for files that can be used to map these values to alternative names. The [JSON API](https://api.opencovid.ca/) is also capable of performing these conversions automatically through the use of the `pt_names` and `hr_names` parameters.

⚠️ **Each time series now ends on the date the data were last updated** (e.g., if case data in a province was updated on January 6 with data up to January 3, the case time series for that province would end on January 3). Previously, every time series ended on the most recent date. However, [exceptions apply](https://github.com/ccodwg/CovidTimelineCanada/issues/40)—some time series end on the most recent date regardless of when the data were updated (this may be corrected in the future). Time series data with rows up to the most recent date for every time series are available from the `timeseries` route of the [API](https://api.opencovid.ca/) using the `fill=true` parameter. **Note that this means that PT time series data cannot be simply aggregated up into a Canadian time series with additional processing.** Please use the data in `data/can` or the API for ready-to-use Canadian time series.

❗ For convenience, **case and death datasets using the old column names, date format, province/territory names and health region names are being offered for download as CSV files**. These files should be more-or-less drop-in replacements for the old case and death datasets. However, we encourage users to switch to the new dataset format, as this legacy format will not be supported indefinitely. Download links for the CSV files:

- [Cases (health regions)](https://api.opencovid.ca/timeseries?stat=cases&geo=hr&legacy=true&fmt=csv)
- [Cases (provinces/territories)](https://api.opencovid.ca/timeseries?stat=cases&geo=pt&legacy=true&fmt=csv)
- [Deaths (health regions)](https://api.opencovid.ca/timeseries?stat=deaths&geo=hr&legacy=true&fmt=csv)
- [Deaths (provinces/territories)](https://api.opencovid.ca/timeseries?stat=deaths&geo=pt&legacy=true&fmt=csv)

💡 Recently added: [vaccine coverage](https://github.com/ccodwg/CovidTimelineCanada/issues/21)

🚨 Coming soon: [vaccine distribution](https://github.com/ccodwg/CovidTimelineCanada/issues/22), [wastewater data](https://github.com/ccodwg/CovidTimelineCanada/issues/36), ["diffs" datasets](https://github.com/ccodwg/CovidTimelineCanada/issues/20) to show changes since the last time a jurisdiction received a data update

This dataset is one component of the **[What Happened? COVID-19 in Canada](https://whathappened.coronavirus.icu/)** project. The goal is for this dataset to eventually conform to the [Data and Metadata Standard for COVID-19 Data in Canada](https://github.com/ccodwg/CovidDataStandard), which is currently being collaboratively developed.

## How to download these data

To download all the datasets in this repository, click the big green "Code" button, then click "Download ZIP". Save it to the location of your choice and unzip the contents. All of the CSV files containing the data can be opened using your spreadsheet software or statistical package of choice.

More advanced queries are available via our JSON API: [https://api.opencovid.ca/](https://api.opencovid.ca/).

## Data format

- name: The name of the metric (e.g., cases, testing)
- province: The two-letter code for the province or territory (e.g., ON, AB)
- sub_region_1: The unique identifier of the health region (e.g., 3595, 594) (this column is absent for PT-level data)
- sub_region_2: The name of the sub-region (e.g., Downtown, Yellowknife) (this column is absent for PT and HR-level data)
- date: The date in YYYY-MM-DD format
- value: The cumulative value (e.g., cumulative number of cases, number of active hospitalizations)
- value_daily: The daily value (e.g., daily number of cases, change in the number of active hospitalizations)

## Contributing

To contribute to this project, please refer to the ongoing discussions in the issues board or open up a new one. We need help identifying the best data sources for each value and harmonizing them into a single dataset. Please add new data sources to the [wiki page](https://github.com/ccodwg/CovidTimelineCanada/wiki/List-of-data-sources).

We must also identify gaps in publicly available data. These data may then be requested from the relevant agencies or acquired via Access to Information requests (see [an example with Sasksatchewan's COVID-19 data](https://data.gripe/covid-19-in-saskatchewan/)).

## How data updates work

The data in this repository are updated using a variety of scripts present in the repository. At present, this process relies on the following R packages:

* [Covid19CanadaData](https://github.com/ccodwg/Covid19CanadaData): Loads the live version of a specified public dataset (denoted by its UUID in [dataset.json](https://github.com/ccodwg/Covid19CanadaArchive/blob/master/datasets.json)) using the function Covid19CanadaData::dl_dataset
* [Covid19CanadaDataProcess](https://github.com/ccodwg/Covid19CanadaDataProcess): Processes a given dataset into a standardized data format
* [Covid19CanadaDataETL](https://github.com/ccodwg/Covid19CanadaETL): The ETL (extract-load-transform) package coordinates downloading, processing and writing the final combined datasets

## Included datasets

The following datasets are included in this repository:

* Cases by province/territory (`data/pt/cases_pt.csv`) and health region (`data/hr/cases_hr.csv`)

![cases](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/cases_pt.png)

![cases](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/cases_hr.png)

* Deaths by province/territory (`data/pt/deaths_pt.csv`) and health region (`data/hr/deaths_hr.csv`)

![deaths](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/deaths_pt.png)

![deaths](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/deaths_hr.png)

* Tests completed by province/territory (`data/pt/tests_completed_pt.csv`)

![testing](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/tests_completed_pt.png)

* Hospitalizations (non-ICU and ICU) by province/territory (`data/pt/hospitalizations_pt.csv`)

![hosp](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/hospitalizations_pt.png)

* ICU occupancy by province/territory (`data/pt/icu_pt.csv`)

![icu](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/icu_pt.png)

* Vaccine coverage (dose 1) by province/territory (`data/pt/vaccine_coverage_dose_1_pt.csv`)

![vaccine_coverage_dose_1](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_1_pt.png)

* Vaccine coverage (dose 2) by province/territory (`data/pt/vaccine_coverage_dose_2_pt.csv`)

![vaccine_coverage_dose_2](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_2_pt.png)

* Vaccine coverage (dose 3) by province/territory (`data/pt/vaccine_coverage_dose_3_pt.csv`)

![vaccine_coverage_dose_3](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_3_pt.png)

Both the cumulative values (`value`) and the daily differences (`value_daily`) are given for each date where data are available.

## Detailed description of data sources

<details>
<summary><b>Cases</b></summary>

| P/T   | Data sources                                                                                                                                                                                                           |
|:------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AB    | - Alberta case CSV (2020-03-06–present)                                                                                                                                                                                |
| BC    | - British Columbia case CSV (2020-01-29–present)                                                                                                                                                                       |
| MB    | - Manitoba RHA times series CSV (2020-03-14–2022-03-25)<br>- Manitoba weekly surveillance report (2022-03-26–present)                                                                                                  |
| NB    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-07)<br>- New Brunswick dashboard (2021-03-08–2022-03-29)<br>- New Brunswick COVIDWATCH weekly report (2022-04-02–present)                                           |
| NL    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-15)<br>- Newfoundland & Labrador dashboard (2021-03-16–2022-03-11)<br>- Newfoundland & Labrador dashboard (2022-03-12–present)                                      |
| NS    | - Nova Scotia case CSV (2021-03-15–2021-01-22)<br>- Nova Scotia dashboard (2021-01-23–2021-12-09)<br>- Nova Scotia daily news release (2021-12-10–2022-03-04)<br>- Nova Scotia weekly data report (2022-03-08–present) |
| NT    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–present)                                                                                                                                        |
| NU    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–present)                                                                                                                                        |
| ON    | - CCODWG Covid19Canada dataset (2020-01-25–2020-03-31)<br>- Ontario PHU summary CSV (2020-04-01–present)                                                                                                               |
| PE    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–present)                                                                                                                                        |
| QC    | - INSPQ time series data CSV (2020-01-24–present)                                                                                                                                                                      |
| SK    | - Saskatchewan total cases dashboard & Freedom of Information request (2020-03-11–2022-02-06)<br>- Saskatchewan weekly COVID-19 situation report (2022-02-05–present)                                                  |
| YT    | - Yukon dashboard (2020-03-19–present)                                                                                                                                                                                 |
</details>

<details>
<summary><b>Deaths</b></summary>

| P/T   | Data sources                                                                                                                                                                                                             |
|:------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AB    | - CCODWG Covid19Canada dataset; Alberta case CSV (2020-03-08–present)                                                                                                                                                    |
| BC    | - CCODWG Covid19Canada dataset; British Columbia case CSV (2020-03-08–present)                                                                                                                                           |
| MB    | - Manitoba RHA times series CSV (2020-03-14–2022-03-19)<br>- Manitoba weekly surveillance report (2022-03-26–present)                                                                                                    |
| NB    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-07)<br>- New Brunswick dashboard (2021-03-08–2022-03-29)<br>- New Brunswick COVIDWATCH weekly report (2022-04-02–present)                                             |
| NL    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-15)<br>- Newfoundland & Labrador dashboard (2021-03-16–2022-03-11)<br>- Newfoundland & Labrador dashboard (2022-03-12–present)                                        |
| NS    | - CCODWG Covid19Canada dataset (2020-01-25–2021-01-18)<br>- Nova Scotia dashboard (2021-01-19–2022-01-18)<br>- Nova Scotia dashboard (2021-01-23–2021-12-09)<br>- Nova Scotia daily news release (2021-12-10–2022-03-04) |
| NT    | - Public Health Agency of Canada daily epidemiology update (2020-01-31–present)                                                                                                                                          |
| NU    | - Public Health Agency of Canada daily epidemiology update (2020-01-31–present)                                                                                                                                          |
| ON    | - CCODWG Covid19Canada dataset (2020-01-25–2020-03-31)<br>- Ontario PHU summary CSV (2022-04-01–present)                                                                                                                 |
| PE    | - Public Health Agency of Canada daily epidemiology update (2020-01-31–present)                                                                                                                                          |
| QC    | - INSPQ time series data CSV (2020-01-24–present)                                                                                                                                                                        |
| SK    | - Saskatchewan total cases dashboard & Freedom of Information request (2020-04-04–2022-02-06)<br>- Saskatchewan weekly COVID-19 situation report (2022-02-05–present)                                                    |
| YT    | - Public Health Agency of Canada daily epidemiology update (2020-01-31–present)                                                                                                                                          |
</details>

<details>
<summary><b>Hospitalizations</b></summary>

| P/T   | Data sources                                                                                                                                                                                                                   |
|:------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AB    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| BC    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| MB    | - covid19tracker.ca dataset (2020-01-25–2021-02-03)<br>- Manitoba dashboard (2021-02-04–2022-03-25)<br>- covid19tracker.ca dataset (2022-03-26–present)                                                                        |
| NB    | - covid19tracker.ca dataset (2020-01-25–2021-03-07)<br>- New Brunswick dashboard (2021-03-08–2021-09-19)<br>- New Brunswick dashboard (2021-09-20–2022-03-29)<br>- New Brunswick COVIDWATCH weekly report (2022-04-02–present) |
| NL    | - Newfoundland & Labrador dashboard (2020-03-27–2022-03-11)<br>- covid19tracker.ca dataset (2022-03-12–present)                                                                                                                |
| NS    | - covid19tracker.ca dataset (2020-01-25–2021-01-18)<br>- Nova Scotia dashboard (2021-01-19–2022-01-18)<br>- covid19tracker.ca dataset (2022-01-19–present)                                                                     |
| NT    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| NU    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| ON    | - Ontario hospitalization CSV (2020-04-02–present)                                                                                                                                                                             |
| PE    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| QC    | - MSSS hospitalization CSV (2020-04-11–present)                                                                                                                                                                                |
| SK    | - Saskatchewan hospitalized cases dashboard (2020-03-26–2022-02-06)<br>- covid19tracker.ca dataset (2022-02-07–present)                                                                                                        |
| YT    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
</details>

<details>
<summary><b>ICU</b></summary>

| P/T   | Data sources                                                                                                                                                                                                                   |
|:------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AB    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| BC    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| MB    | - covid19tracker.ca dataset (2022-03-26–present)<br>- Manitoba dashboard (2021-02-04–2022-03-25)<br>- covid19tracker.ca dataset (2022-03-26–present)                                                                           |
| NB    | - covid19tracker.ca dataset (2020-01-25–2021-03-07)<br>- New Brunswick dashboard (2021-03-08–2021-09-19)<br>- New Brunswick dashboard (2021-09-20–2022-03-29)<br>- New Brunswick COVIDWATCH weekly report (2022-04-02–present) |
| NL    | - covid19tracker.ca dataset (2020-01-25–2021-03-15)<br>- Newfoundland & Labrador dashboard (2021-03-16–2022-03-11)<br>- covid19tracker.ca dataset (2022-03-12–present)                                                         |
| NS    | - covid19tracker.ca dataset (2020-01-25–2021-01-18)<br>- Nova Scotia dashboard (2021-01-19–2022-01-18)<br>- covid19tracker.ca dataset (2022-01-19–present)                                                                     |
| NT    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| NU    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| ON    | - Ontario hospitalization CSV (2020-04-02–present)                                                                                                                                                                             |
| PE    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
| QC    | - MSSS hospitalization CSV (2020-04-11–present)                                                                                                                                                                                |
| SK    | - Saskatchewan hospitalized cases dashboard (2020-03-26–2022-02-06)<br>- covid19tracker.ca dataset (2022-02-07–present)                                                                                                        |
| YT    | - covid19tracker.ca dataset (2020-01-25–present)                                                                                                                                                                               |
</details>

<details>
<summary><b>Tests completed</b></summary>

All data on completed COVID-19 tests are from the [Public Health Agency of Canada daily epidemiology update](https://health-infobase.canada.ca/covid-19/epidemiological-summary-covid-19-cases.html).
</details>

<details>
<summary><b>Vaccine coverage</b></summary>

**Coming soon!**
</details>

<details>
<summary><b>Vaccine distribution</b></summary>

**Coming soon!**
</details>
