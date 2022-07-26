# Timeline of COVID-19 in Canada

The Timeline of COVID-19 in Canada (`CovidTimelineCanada`) is intended to be the definitive source for data regarding the COVID-19 pandemic in Canada. In addition to making available the ready-to-use datasets, this repository also acts as a hub for collaboration on expanding and improving the availability and quality of COVID-19 data in Canada.

Datasets in this repository are found in the [`data`](https://github.com/ccodwg/CovidTimelineCanada/tree/main/data) directory and are updated automatically several times per day by [`Covid19CanadaBot`](https://github.com/ccodwg/Covid19CanadaBot). Map, population and other spatial data are provided in the [`geo`](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory.

This repository is maintained by the [COVID-19 Canada Open Data Working Group](https://opencovid.ca/) and is one component of the **[What Happened? COVID-19 in Canada](https://whathappened.coronavirus.icu/)** project. The data in this repository will eventually conform to the [Data and Metadata Standard for COVID-19 Data in Canada](https://github.com/ccodwg/CovidDataStandard), which is undergoing collaborative development.

Note that on April 30, 2022, `CovidTimelineCanada` superseded the original **[`Covid19Canada`](https://github.com/ccodwg/Covid19Canada)** dataset, which was first made available in March of 2020. For those familiar with the original dataset, please see the notes below about working with the new dataset.

<details>
<summary><b>Transitioning from <code>Covid19Canada</code> to <code>CovidTimelineCanada</code></b> (click to expand)</summary>

  ⚠️ **Province/territory (PT) names are now given using two-letter codes and health region (HR) names are given using unique identifiers**. See the [geo](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory for files that can be used to map these values to alternative names. The [JSON API](https://api.opencovid.ca/) is also capable of performing these conversions automatically through the use of the `pt_names` and `hr_names` parameters.

  ⚠️ **Each time series now ends on the date the data were last updated** (e.g., if case data in a province was updated on January 6 with data up to January 3, the case time series for that province would end on January 3). Previously, every time series ended on the most recent date. Time series data with rows up to the most recent date for every time series are available from the `timeseries` route of the [API](https://api.opencovid.ca/) using the `fill=true` parameter. This also means that PT time series data cannot be simply aggregated up into a Canadian time series without additional processing—ready-to-use Canadian data are provided in `data/can` or through the API. **Note that the Canadian time series should be considered incomplete since many provinces/territories have not provided data for the most recent dates.**

  ❗ For convenience, **case and death datasets using the old column names, date format, province/territory names and health region names are being offered for download as CSV files**. These files should be more-or-less drop-in replacements for the old case and death datasets. However, we encourage users to switch to the new dataset format, as this legacy format will not be supported indefinitely. Download links for the CSV files:

  - [Cases (health regions)](https://api.opencovid.ca/timeseries?stat=cases&geo=hr&legacy=true&fmt=csv)
  - [Cases (provinces/territories)](https://api.opencovid.ca/timeseries?stat=cases&geo=pt&legacy=true&fmt=csv)
  - [Deaths (health regions)](https://api.opencovid.ca/timeseries?stat=deaths&geo=hr&legacy=true&fmt=csv)
  - [Deaths (provinces/territories)](https://api.opencovid.ca/timeseries?stat=deaths&geo=pt&legacy=true&fmt=csv)
</details>

Some recent announcements regarding the dataset:

- 💡 Recently added: [vaccine coverage](https://github.com/ccodwg/CovidTimelineCanada/issues/21) (doses 1–4), [vaccine administration](https://github.com/ccodwg/CovidTimelineCanada/issues/47) (doses 1–3, total doses)
 
- 🚨 Coming soon: [vaccine distribution](https://github.com/ccodwg/CovidTimelineCanada/issues/22), [wastewater data](https://github.com/ccodwg/CovidTimelineCanada/issues/36), ["diffs" datasets](https://github.com/ccodwg/CovidTimelineCanada/issues/20) to show changes since the last time a jurisdiction received a data update

## How to download these data

To download all the datasets in this repository, click the big green "Code" button, then click "Download ZIP". Save it to the location of your choice and unzip the contents. All of the CSV files containing the data can be opened using your spreadsheet software or statistical package of choice.

Individual CSV files in the `data` directory may be downloaded by right clicking the "Raw" button on the page and selecting "Save link as...".

More complex queries are available via our API: [https://api.opencovid.ca/](https://api.opencovid.ca/), which can return data in JSON or CSV format. This is the preferred option for advanced data users.

## Data format

- `name`: The name of the metric (e.g., cases, testing)
- `province`: The two-letter code for the province or territory (e.g., ON, AB)
- `sub_region_1`: The unique identifier of the health region (e.g., 3595, 594) (this column is absent for PT-level data)
- `sub_region_2`: The name of the sub-region (e.g., Downtown, Yellowknife) (this column is absent for PT and HR-level data)
- `date`: The date in YYYY-MM-DD format
- `value`: The cumulative value (e.g., cumulative number of cases, number of active hospitalizations)
- `value_daily`: The daily value (e.g., daily number of cases, change in the number of active hospitalizations)

## Citation and terms of use

Datasets in our repository are provided under the [Creative Commons Attribution 4.0 International license (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Software and scripts in our repository are provided under the [MIT license](https://opensource.org/licenses/MIT).

Please see [our license file](https://github.com/ccodwg/CovidTimelineCanada/blob/main/LICENSE.md) for a full list of acknowledgements of data sources used in this repository as well as copies of the aforementioned licenses.

We recommend using the citation below:

Berry, I., O’Neill, M., Sturrock, S. L., Wright, J. E., Acharya, K., Brankston, G., Harish, V., Kornas, K., Maani, N., Naganathan, T., Obress, L., Rossi, T., Simmons, A. E., Van Camp, M., Xie, X., Tuite, A. R., Greer, A. L., Fisman, D. N., & Soucy, J.-P. R. (2021). A sub-national real-time epidemiological and vaccination database for the COVID-19 pandemic in Canada. Scientific Data, 8(1). doi: [https://doi.org/10.1038/s41597-021-00955-2](https://doi.org/10.1038/s41597-021-00955-2)

Please find a biblatex file [here](/docs/covidtimelinecanada.bib). 

Previously, we recommended the following citation:

Berry, I., Soucy, J.-P. R., Tuite, A., & Fisman, D. (2020). Open access epidemiologic data and an interactive dashboard to monitor the COVID-19 outbreak in Canada. Canadian Medical Association Journal, 192(15), E420. doi: [https://doi.org/10.1503/cmaj.75262](https://doi.org/10.1503/cmaj.75262)

## Contributing

To contribute to this project, please refer to the ongoing discussions in the issues board or open up a new one. We need help identifying the best data sources for each value and harmonizing them into a single dataset. Please add new data sources to the [wiki page](https://github.com/ccodwg/CovidTimelineCanada/wiki/List-of-data-sources).

We must also identify gaps in publicly available data. These data may then be requested from the relevant agencies or acquired via Access to Information requests (see [an example with Sasksatchewan's COVID-19 data](https://data.gripe/covid-19-in-saskatchewan/)).

## Included datasets

The following datasets are included in this repository:

* Cases by province/territory (`data/pt/cases_pt.csv`) and health region (`data/hr/cases_hr.csv`)
  <details>
   <summary><b>Plots</b> (click to expand)</summary>

   ![cases](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/cases_pt.png)
   ![cases](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/cases_hr.png)

  </details>

* Deaths by province/territory (`data/pt/deaths_pt.csv`) and health region (`data/hr/deaths_hr.csv`)
  <details>
   <summary><b>Plots</b> (click to expand)</summary>

   ![deaths](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/deaths_pt.png)
   ![deaths](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/deaths_hr.png)

  </details>

* Tests completed by province/territory (`data/pt/tests_completed_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

  ![testing](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/tests_completed_pt.png)

  </details>

* Hospitalizations (non-ICU and ICU) by province/territory (`data/pt/hospitalizations_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![hosp](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/hospitalizations_pt.png)

  </details>

* ICU occupancy by province/territory (`data/pt/icu_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![icu](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/icu_pt.png)

  </details>

* Vaccine coverage (dose 1) by province/territory (`data/pt/vaccine_coverage_dose_1_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_coverage_dose_1](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_1_pt.png)

  </details>

* Vaccine coverage (dose 2) by province/territory (`data/pt/vaccine_coverage_dose_2_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_coverage_dose_2](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_2_pt.png)

  </details>

* Vaccine coverage (dose 3) by province/territory (`data/pt/vaccine_coverage_dose_3_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_coverage_dose_3](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_3_pt.png)

  </details>

* Vaccine coverage (dose 4) by province/territory (`data/pt/vaccine_coverage_dose_4_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_coverage_dose_4](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_coverage_dose_4_pt.png)

  </details>

* Vaccine administration (total doses) by province/territory (`data/pt/vaccine_administration_total_doses_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_administration_total_doses](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_administration_total_doses_pt.png)

  </details>

* Vaccine administration (dose 1) by province/territory (`data/pt/vaccine_administration_dose_1_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_administration_dose_1](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_administration_dose_1_pt.png)

  </details>

* Vaccine administration (dose 2) by province/territory (`data/pt/vaccine_administration_dose_2_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_administration_dose_2](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_administration_dose_2_pt.png)

  </details>

* Vaccine administration (dose 3) by province/territory (`data/pt/vaccine_administration_dose_3_pt.csv`)
  <details>
   <summary><b>Plot</b> (click to expand)</summary>

   ![vaccine_administration_dose_3](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanadaPlots/main/plots/vaccine_administration_dose_3_pt.png)

  </details>

Both the cumulative values (`value`) and the daily differences (`value_daily`) are given for each date where data are available.

## How these data are kept up to date

The data in this repository are updated several times per day by [`Covid19CanadaBot`](https://github.com/ccodwg/Covid19CanadaBot) using the script [`update_data.R`](https://github.com/ccodwg/CovidTimelineCanada/blob/main/update_data.R). At present, this process relies on the following R packages:

* [`Covid19CanadaData`](https://github.com/ccodwg/Covid19CanadaData): Loads the live version of a specified public dataset (denoted by its UUID in [`dataset.json`](https://github.com/ccodwg/Covid19CanadaArchive/blob/master/datasets.json)) using the function `Covid19CanadaData::dl_dataset`
* [`Covid19CanadaDataProcess`](https://github.com/ccodwg/Covid19CanadaDataProcess): Processes a given dataset into a standardized data format
* [`Covid19CanadaDataETL`](https://github.com/ccodwg/Covid19CanadaETL): The ETL (extract-transform-load) package coordinates downloading, processing and writing the final combined datasets

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
| NT    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                 |
| NU    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                 |
| ON    | - CCODWG Covid19Canada dataset (2020-01-25–2020-03-31)<br>- Ontario PHU summary CSV (2020-04-01–present)                                                                                                               |
| PE    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                 |
| QC    | - INSPQ time series data CSV (2020-01-24–present)                                                                                                                                                                      |
| SK    | - Saskatchewan total cases dashboard & Freedom of Information request (2020-03-11–2022-02-06)<br>- Saskatchewan weekly COVID-19 situation report (2022-02-05–present)                                                  |
| YT    | - Yukon dashboard (2020-03-19–present)                                                                                                                                                                                 |
</details>

<details>
<summary><b>Deaths</b></summary>

| P/T   | Data sources                                                                                                                                                                                                                                     |
|:------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AB    | - CCODWG Covid19Canada dataset (2020-03-08–2020-06-22)<br>- Alberta case CSV (2020-06-23–present)                                                                                                                                                |
| BC    | - CCODWG Covid19Canada dataset (2020-03-08–2022-04-01)<br>- British Columbia dashboard (2022-04-02–present)                                                                                                                                      |
| MB    | - Manitoba RHA times series CSV (2020-03-14–2022-03-19)<br>- Manitoba weekly surveillance report (2022-03-26–present)                                                                                                                            |
| NB    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-07)<br>- New Brunswick dashboard (2021-03-08–2022-03-29)<br>- New Brunswick COVIDWATCH weekly report (2022-04-02–present)                                                                     |
| NL    | - CCODWG Covid19Canada dataset (2020-01-25–2021-03-15)<br>- Newfoundland & Labrador dashboard (2021-03-16–2022-03-11)<br>- Newfoundland & Labrador dashboard (2022-03-15–2022-05-05)<br>- Newfoundland & Labrador dashboard (2022-05-06–present) |
| NS    | - CCODWG Covid19Canada dataset (2020-01-25–2021-01-18)<br>- Nova Scotia dashboard (2021-01-19–2022-01-18)<br>- Nova Scotia dashboard (2021-01-23–2021-12-09)<br>- Nova Scotia daily news release (2021-12-10–2022-03-04)                         |
| NT    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                                           |
| NU    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                                           |
| ON    | - CCODWG Covid19Canada dataset (2020-01-25–2020-03-31)<br>- Ontario PHU summary CSV (2022-04-01–present)                                                                                                                                         |
| PE    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                                           |
| QC    | - INSPQ time series data CSV (2020-01-24–present)                                                                                                                                                                                                |
| SK    | - Saskatchewan total cases dashboard & Freedom of Information request (2020-04-04–2022-02-06)<br>- Saskatchewan weekly COVID-19 situation report (2022-02-05–present)                                                                            |
| YT    | - Public Health Agency of Canada daily epidemiology update (2020-03-11–2022-06-08)<br>- Public Health Agency of Canada weekly epidemiology update (2022-06-11–present)                                                                           |
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

| P/T   | Data sources                                                              |
|:------|:--------------------------------------------------------------------------|
| AB    | - COVID-19 Alberta statistics app (2020-01-04–present)                    |
| BC    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| MB    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| NB    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| NL    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| NS    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| NT    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| NU    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| ON    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| PE    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| QC    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| SK    | - Public Health Agency of Canada epidemiology update (2020-01-01–present) |
| YT    | - Yukon dashboard (2020-02-27–present)                                    |
</details>

<details>
<summary><b>Vaccine coverage</b></summary>

All data on COVID-19 vaccine coverage are from the [Public Health Agency of Canada vaccination coverage page](https://health-infobase.canada.ca/covid-19/vaccination-coverage/).
</details>

<details>
<summary><b>Vaccine administration</b></summary>

All data on COVID-19 vaccine administration are from the [Public Health Agency of Canada vaccine administration page](https://health-infobase.canada.ca/covid-19/vaccine-administration/).
</details>

<details>
<summary><b>Vaccine distribution</b></summary>

**Coming soon!**
</details>

## Acknowledgements

We would like to thank all the individuals and organizations across Canada who have worked tirelessly to provide data to the public during this pandemic.

Additionally, we acknowledge the following individuals and organizations for their support:

[Public Health Agency of Canada](https://www.canada.ca/en/public-health.html) / Joe Murray ([JMA Consulting](https://jmaconsulting.biz/home))

## Contact us

More information about the COVID-19 Canada Open Data Working Group is available at [our website](https://opencovid.ca/). We may also be reached through our [contact page](https://opencovid.ca/contact-us/).
