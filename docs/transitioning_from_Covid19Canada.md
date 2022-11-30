## Transitioning from `Covid19Canada`

On April 30, 2022, `CovidTimelineCanada` superseded the original [`Covid19Canada`](https://github.com/ccodwg/Covid19Canada) dataset, which was first made available in March of 2020. This document offers some useful information for those converting their workflows to use the new dataset.

⚠️ **Province/territory (PT) names are now given using two-letter codes and health region (HR) names are given using unique identifiers**. See the [geo](https://github.com/ccodwg/CovidTimelineCanada/tree/main/geo) directory for files that can be used to map these values to alternative names. The [JSON API](https://api.opencovid.ca/) is also capable of performing these conversions automatically through the use of the `pt_names` and `hr_names` parameters.

⚠️ **Each time series now ends on the date the data were last updated** (e.g., if case data in a province was updated on January 6 with data up to January 3, the case time series for that province would end on January 3). Previously, every time series ended on the most recent date. Time series data with rows up to the most recent date for every time series are available from the `timeseries` route of the [API](https://api.opencovid.ca/) using the `fill=true` parameter. This also means that PT time series data cannot be simply aggregated up into a Canadian time series without additional processing—ready-to-use Canadian data are provided in `data/can` or through the API. **Note that the Canadian time series should be considered incomplete since many provinces/territories have not provided data for the most recent dates.**

❗ For convenience, **case and death datasets using the old column names, date format, province/territory names and health region names are being offered for download as CSV files**. These files should be more-or-less drop-in replacements for the old case and death datasets. However, we encourage users to switch to the new dataset format, as this legacy format will not be supported indefinitely. Download links for the CSV files:

- [Cases (health regions)](https://api.opencovid.ca/timeseries?stat=cases&geo=hr&legacy=true&fmt=csv)
- [Cases (provinces/territories)](https://api.opencovid.ca/timeseries?stat=cases&geo=pt&legacy=true&fmt=csv)
- [Deaths (health regions)](https://api.opencovid.ca/timeseries?stat=deaths&geo=hr&legacy=true&fmt=csv)
- [Deaths (provinces/territories)](https://api.opencovid.ca/timeseries?stat=deaths&geo=pt&legacy=true&fmt=csv)
