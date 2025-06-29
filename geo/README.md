# Geographic data

Comprehensive names and population data are available for health regions in `hr.csv`, provinces/territories in `pt.csv` and Canada in `can.csv`.

## Map files

Map files are available in GeoJSON format for health regions in `hr.geojson`, provinces/territories in `pt.geojson` and Canada in `can.geojson`. The map files are derived from TopoJSON files available from the [Public Health Agency of Canada's epidemiology update](https://health-infobase.canada.ca/covid-19/): [health-regions-2022.json](https://health-infobase.canada.ca/src/json/health-regions-2022.json) and [Can_PR2016.json](https://health-infobase.canada.ca/src/json/Can_PR2016.json). Both map files use the NAD83 / Statistics Canada Lambert projection ([EPSG:3347](https://epsg.io/3347)). Unprojected versions of the map files using WGS84 ([EPSG:4326](https://epsg.io/4326)) are available as `hr_wgs84.geojson`, `pt_wgs84.geojson` and `can_wgs84.geojson`.

Note that the map files do not contain detailed name and population data. However, these data may be added by joining `hr.csv`, `pt.csv` or `can.csv`, as desired.

## Health regions

Health region names and unique identifiers (HRUIDs) were derived from the [2018 health region boundary files](https://www150.statcan.gc.ca/n1/pub/82-402-x/2018001/hrbf-flrs-eng.htm) from Statistics Canada. The following changes were made to reflect updates to health region boundaries and to match the geography used by the province/territory to report COVID-19 data:

* Renamed Oxford Elgin St. Thomas Health Unit / Circonscription sanitaire d’Oxford, Elgin et St. Thomas (3575) to Southwestern Public Health Unit / Circonscription sanitaire du Sud-Ouest (3575)
* Removed Huron County Health Unit / Circonscription sanitaire du comté de Huron (3539) and Perth District Health Unit / Circonscription sanitaire du district de Perth (3554) and replaced with Huron Perth Public Health Unit / Circonscription sanitaire de Huron et Perth (3550) to match the [September 2023 health region boundary files](https://www150.statcan.gc.ca/n1/pub/82-402-x/82-402-x2024001-eng.htm)
  * This amalgamated health unit was previously given the HRUID 3539, as it did not have an official designation prior to the [December 2022 health region boundary files](https://www150.statcan.gc.ca/n1/pub/82-402-x/82-402-x2023001-eng.htm)
* Replaced British Columbia's 16 Health Service Delivery Areas (5911, 5912, 5913, 5914, 5921, 5922, 5923, 5931, 5932, 5933, 5941, 5942, 5943, 5951, 5952, 5953) with the 5 amalgamated Regional Health Authorities (591, 592, 593, 594, 595) to reflect the level at which COVID-19 data were reported in the province
* Replaced Saskatchewan's 13 Regional Health Authorities (4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713) with the [13 zones used to report COVID-19 data in the province after August 2020](https://web.archive.org/web/20200803220240/https://www.saskatchewan.ca/government/news-and-media/2020/august/03/covid-19-update-august-3) (4711, 4712, 4713, 4721, 4722, 4723, 4731, 4732, 4741, 4751, 4761, 4762, 4763)
  * The HRUIDs for Sasketchwan's 13 zones are unofficial and were created by appending a fourth, incrementing digit to the end of the previous [6 amalgamated zones used to report COVID-19 data](https://web.archive.org/web/20200803220240/https://www.saskatchewan.ca/government/news-and-media/2020/august/03/covid-19-update-august-3) (471, 472, 473, 474, 475, 476)
  * The 7 zones in the [September 2023 health region boundary files](https://www150.statcan.gc.ca/n1/pub/82-402-x/82-402-x2024001-eng.htm) (4721, 4722, 4723, 4724, 4725, 4726, 4727) do not correspond to the 13 zones used by the province to report COVID-19 data; however, some of the HRUIDs of these new zones overlap with the HRUIDs created for this dataset (but **do not** correspond to the same areas)

## Population data

Population data for both health regions and provinces/territories are available for various time periods in columns beginning with `pop_`. The canonical population (i.e., the most recent population available for a particular geography) is found in the column `pop`. Health region population data are available as annual mid-year estimates, whereas province/territory population data are available as quarterly estimates.

Provincial population estimates for Saskatchewan will differ from the sum of the Saskatchewan health region estimates due to different data sources (see details below).

### Health regions

Mid-year population estimates (2019–2023) for health regions (excluding Saskatchewan) were obtained from Statistics Canada [Table 17-10-0157-01 Population estimates, July 1, by health region and peer group, 2023 boundaries](https://doi.org/10.25318/1710015701-eng).

Population estimates for British Columbia's 5 Regional Health Authorities were created by aggregating the values for the constituent 16 Health Service Delivery Areas. Population estimates for Newfoundland and Labrador's 4 Regional Health Authorities were created from the 5 Zones introduced in the 2023 boundaries (Central, Western, Labrador-Grenfell were unchanged and Eastern was amalgamated from the new Eastern Urban and Eastern Rural Zones).

For Saskatchewan's 13 zones, population estimates were obtained from the [saskatchewan.ca dashboard](https://dashboard.saskatchewan.ca/health-wellness), aggregated up from the province's 32 sub-zones. These estimates are assumed to correspond to mid-year estimates, similar to other health region population data, although they differ slightly from Statistics Canada's province-wide population estimates for the province. Population estimates were only available for [2020](https://web.archive.org/web/20201006213033/https://dashboard.saskatchewan.ca/api/health/subgeography/summary) and [2021](https://web.archive.org/web/20210717040047/https://dashboard.saskatchewan.ca/api/health/subgeography/summary).

### Provinces/territories

Quarterly population estimates (2020 Q1–2023 Q4) for provinces/territories were obtained from Statistics Canada [Table 17-10-0009-01 Population estimates, quarterly](https://doi.org/10.25318/1710000901-eng).

### Canada

Quarterly population estimates (2020 Q1–2023 Q4) for Canada were obtained from Statistics Canada [Table 17-10-0009-01 Population estimates, quarterly](https://doi.org/10.25318/1710000901-eng).
