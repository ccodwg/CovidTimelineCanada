# Timeline of COVID-19 in Canada

The Timeline of COVID-19 in Canada (`CovidTimelineCanada`) is intended to be the definitive source for data regarding the COVID-19 pandemic in Canada. In addition to making available the ready-to-use datasets, this repository also acts as a hub for collaboration on expanding and improving the availability and quality of COVID-19 data in Canada. This repository is maintained by the [COVID-19 Canada Open Data Working Group](https://opencovid.ca/) and is one component of the **[What Happened? COVID-19 in Canada](https://whathappened.coronavirus.icu/)** project. Our work has been cited or republished by numerous organizations, researchers, and journalists: see [Citation and terms of use](#citation-and-terms-of-use) for some examples.

Datasets in this repository are found in the [`data`](https://github.com/ccodwg/CovidTimelineCanada/tree/main/data) directory and are [updated automatically several times per day](#how-these-data-are-updated). Map, population and other spatial data are provided in the [`geo`](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory. A [Detailed description of data sources](docs/data_sources/data_sources.md) is also available.

On April 30, 2022, `CovidTimelineCanada` superseded the original [`Covid19Canada`](https://github.com/ccodwg/Covid19Canada) dataset, which was first made available in March of 2020. For those familiar with the original dataset, please see [Transitioning from `Covid19Canada`](docs/transitioning_from_Covid19Canada.md).

A simple [dashboard](https://ccodwg.github.io/CovidTimelineCanada-js-dashboard/) is available to explore the data available in the Timeline of COVID-19 in Canada dataset.

## Getting started

We offer three groups of datasets: health region-level (`hr`), for case and death data only, province/territory-level (`pt`), for all data types, and Canada-level (`can`), for all data types. Because each province/territory has a different update schedule, the most recent date of data for each region is different; for the same reason, the Canada-level data are incomplete in [recent](https://github.com/ccodwg/CovidTimelineCanada/blob/main/data/can/cases_can_completeness.json) [days](https://github.com/ccodwg/CovidTimelineCanada/blob/main/data/can/deaths_can_completeness.json).

To download all of the datasets in this repository, click the big green "Code" button, then click "Download ZIP". Save it to the location of your choice and unzip the contents. All of the CSV files containing the data can be opened using your spreadsheet software or statistical package of choice. Alternatively, you can download individual CSV files in the [`data`](https://github.com/ccodwg/CovidTimelineCanada/tree/main/data) directory by right clicking the "Raw" button on the page and selecting "Save link as...".

For a list of available datasets see [Available datasets](#available-datasets) and for an explanation of the data format see [Data format](#data-format).

For more advanced users or those wanting an always-up-to-date data source, we recommend using our API ([https://api.opencovid.ca/](https://api.opencovid.ca/)), which can return data in JSON or CSV format.

Below is an example query that will return the latest 7 days of case data for each province/territory (again, the dates will be different for each region because of their differing update schedules) in JSON format:

```
https://api.opencovid.ca/timeseries?stat=cases&geo=pt&date=7
```

The next query will return the latest day of case data for each health region in JSON format:

```
https://api.opencovid.ca/timeseries?stat=cases&geo=hr&hr_names=short&date=1
```

Some provinces no longer offer health region-level data for cases and/or deaths. For these provinces/territories, all recent cases and/or deaths will show up under the "Unknown" (code: 9999) health region. See [Health region-level data reporting](docs/data_sources/hr_reporting.md) for details on if and when this transition occured for each province.

## Available datasets

The following datasets are available:

- Cases (`cases`) (health region or province/territory)
- Deaths (`deaths`) (health region or province/territory)
- Active hospitalizations (`hospitalizations`)
- Active ICU (`icu`)
- Tests completed (`tests_completed`)
- Vaccine coverage by dose (`vaccine_coverage_dose_1`, `vaccine_coverage_dose_2`, `vaccine_coverage_dose_3`, `vaccine_coverage_dose_4`)
- Vaccine administration by dose (`vaccine_administration_total_doses`, `vaccine_administration_dose_1`, `vaccine_administration_dose_2`, `vaccine_administration_dose_3`, `vaccine_administration_dose_4`, `vaccine_administration_dose_5plus`)
- Vaccine distribution (`vaccine_distribution_total_doses`)

While we do our best to ensure comparability for the same metrics across different provinces/territories, some regions use different difinitions for the same metric (e.g., how COVID-19 deaths are defined). Reporting of a metric may also change over time in the same region.

For more information on each value, including definitions, see the [Technical report](docs/technical_report/technical_report.md) and the [Detailed description of data sources](docs/data_sources/data_sources.md).

For a summary plot of each dataset, see our [dashboard](https://ccodwg.github.io/CovidTimelineCanada-js-dashboard/).

## Data format

- `name`: The name of the metric (e.g., cases, testing)
- `province`: The two-letter code for the province or territory (e.g., ON, AB)
- `sub_region_1`: The unique identifier of the health region (e.g., 3595, 594) (this column is absent for PT-level data)
- `date`: The date in YYYY-MM-DD format
- `value`: The cumulative value (e.g., cumulative number of cases, number of active hospitalizations)
- `value_daily`: The daily value (e.g., daily number of cases, change in the number of active hospitalizations)

## Citation and terms of use

Datasets in our repository are provided under the [Creative Commons Attribution 4.0 International license (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Software and scripts in our repository are provided under the [MIT license](https://opensource.org/licenses/MIT).

Please see [our license file](https://github.com/ccodwg/CovidTimelineCanada/blob/main/LICENSE.md) for a full list of acknowledgements of data sources used in this repository as well as copies of the aforementioned licenses.

We recommend using the citation below:

> Berry, I., O’Neill, M., Sturrock, S. L., Wright, J. E., Acharya, K., Brankston, G., Harish, V., Kornas, K., Maani, N., Naganathan, T., Obress, L., Rossi, T., Simmons, A. E., Van Camp, M., Xie, X., Tuite, A. R., Greer, A. L., Fisman, D. N., & Soucy, J.-P. R. (2021). A sub-national real-time epidemiological and vaccination database for the COVID-19 pandemic in Canada. Scientific Data, 8(1). doi: [https://doi.org/10.1038/s41597-021-00955-2](https://doi.org/10.1038/s41597-021-00955-2)

A BibTeX file for the citation is available [here](https://raw.githubusercontent.com/ccodwg/CovidTimelineCanada/main/docs/citation/CovidTimelineCanada.bib).

Previously, we recommended the following citation:

> Berry, I., Soucy, J.-P. R., Tuite, A., & Fisman, D. (2020). Open access epidemiologic data and an interactive dashboard to monitor the COVID-19 outbreak in Canada. Canadian Medical Association Journal, 192(15), E420. doi: [https://doi.org/10.1503/cmaj.75262](https://doi.org/10.1503/cmaj.75262)

Our data have been used by numerous organizations, journalists, and researchers (Google Scholar: [new paper](https://scholar.google.ca/scholar?oi=bibs&hl=en&cites=9698187328395226586), [old paper](https://scholar.google.ca/scholar?oi=bibs&hl=en&cites=16785861098617080456)). Our datasets have also been republished by groups such as the [Public Health Agency of Canada](https://health-infobase.canada.ca/covid-19/current-situation.html) (health region map), [Google](https://health.google.com/covid-19/open-data/data-sources), and [Our World in Data](https://web.archive.org/web/20210105130856/https://ourworldindata.org/covid-vaccinations#source-information-country-by-countryorg/covid-vaccinations).

## Contributing

To contribute to this project, please [open an issue on GitHub](https://github.com/ccodwg/CovidTimelineCanada/issues). We can also be reached via our [contact page](https://opencovid.ca/contact-us/).

## How these data are updated

The data in this repository are updated several times per day by [`Covid19CanadaBot`](https://github.com/ccodwg/Covid19CanadaBot).

## Detailed description of data sources

See [Detailed description of data sources](docs/data_sources/data_sources.md).

## Extra datasets

See [Extra datasets](extra_data#extra-datasets) for details about datasets in the `extra_data` directory.

## Acknowledgements

We would like to thank all the individuals and organizations across Canada who have worked tirelessly to provide data to the public during this pandemic.

Additionally, we acknowledge the following individuals and organizations for their support:

[Public Health Agency of Canada](https://www.canada.ca/en/public-health.html) / Joe Murray ([JMA Consulting](https://jmaconsulting.biz/home))

## Contact us

More information about the COVID-19 Canada Open Data Working Group is available at [our website](https://opencovid.ca/). We may also be reached through our [contact page](https://opencovid.ca/contact-us/).
