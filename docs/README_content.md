# Timeline of COVID-19 in Canada

The purpose of this repository is to collaborate on assembling a definitive dataset for COVID-19 in Canada.

⚠️ Beginning April 30, this dataset replaced the original **[Covid19Canada](https://github.com/ccodwg/Covid19Canada)** dataset.

⚠️ Note that **province/territory (PT) names are now given using two-letter codes and health region (HR) names are given using unique identifiers**. See the [geo](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory for files that can be used to map these values to alternative names. The [JSON API](https://api.opencovid.ca/) is also capable of performing these conversions automatically through the use of the `pt_names` and `hr_names` parameters.

⚠️ **Each time series now ends on the date the data were last updated** (e.g., if case data in a province was updated on January 6 with data up to January 3, the case time series for that province would end on January 3). Previously, every time series ended on the most recent date. Time series data with rows up to the most recent date for every time series are available from the `timeseries` route of the [API](https://api.opencovid.ca/) using the `fill=true` parameter. This also means that PT time series data cannot be simply aggregated up into a Canadian time series without additional processing—ready-to-use Canadian data are provided in `data/can` or through the API. **Note that the Canadian time series should be considered incomplete since many provinces/territories have not provided data for the most recent dates.**

❗ For convenience, **case and death datasets using the old column names, date format, province/territory names and health region names are being offered for download as CSV files**. These files should be more-or-less drop-in replacements for the old case and death datasets. However, we encourage users to switch to the new dataset format, as this legacy format will not be supported indefinitely. Download links for the CSV files:

- [Cases (health regions)](https://api.opencovid.ca/timeseries?stat=cases&geo=hr&legacy=true&fmt=csv)
- [Cases (provinces/territories)](https://api.opencovid.ca/timeseries?stat=cases&geo=pt&legacy=true&fmt=csv)
- [Deaths (health regions)](https://api.opencovid.ca/timeseries?stat=deaths&geo=hr&legacy=true&fmt=csv)
- [Deaths (provinces/territories)](https://api.opencovid.ca/timeseries?stat=deaths&geo=pt&legacy=true&fmt=csv)

💡 Recently added: [vaccine coverage](https://github.com/ccodwg/CovidTimelineCanada/issues/21) (doses 1–4), [vaccine administration](https://github.com/ccodwg/CovidTimelineCanada/issues/47) (doses 1–3, total doses)
 
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

## Citation and terms of use

Datasets in our repository are provided under the [Creative Commons Attribution 4.0 International license (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Software and scripts in our repository are provided under the [MIT license](https://opensource.org/licenses/MIT).

Please see [our license file](https://github.com/ccodwg/CovidTimelineCanada/blob/main/LICENSE.md) for a full list of acknowledgements of data sources used in this repository as well as copies of the aforementioned licenses.

We recommend using the citation below:

Berry, I., O’Neill, M., Sturrock, S. L., Wright, J. E., Acharya, K., Brankston, G., Harish, V., Kornas, K., Maani, N., Naganathan, T., Obress, L., Rossi, T., Simmons, A. E., Van Camp, M., Xie, X., Tuite, A. R., Greer, A. L., Fisman, D. N., & Soucy, J.-P. R. (2021). A sub-national real-time epidemiological and vaccination database for the COVID-19 pandemic in Canada. Scientific Data, 8(1). doi: [https://doi.org/10.1038/s41597-021-00955-2](https://doi.org/10.1038/s41597-021-00955-2)

Previously, we recommended the following citation:

Berry, I., Soucy, J.-P. R., Tuite, A., & Fisman, D. (2020). Open access epidemiologic data and an interactive dashboard to monitor the COVID-19 outbreak in Canada. Canadian Medical Association Journal, 192(15), E420. doi: [https://doi.org/10.1503/cmaj.75262](https://doi.org/10.1503/cmaj.75262)

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

## Detailed description of data sources

<!-- data sources -->

## Acknowledgements

We would like to thank all the individuals and organizations across Canada who have worked tirelessly to provide data to the public during this pandemic.

Additionally, we acknowledge the following individuals and organizations for their support:

[Public Health Agency of Canada](https://www.canada.ca/en/public-health.html) / Joe Murray ([JMA Consulting](https://jmaconsulting.biz/home))

## Contact us

More information about the COVID-19 Canada Open Data Working Group is available at [our website](https://opencovid.ca/). We may also be reached through our [contact page](https://opencovid.ca/contact-us/).
