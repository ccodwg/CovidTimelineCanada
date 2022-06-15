# Geographic data

Comprehensive names and population data are available for provinces/territories in `pt.csv` and for health regions in `health_regions.csv`.

## Map files

Map files are available in GeoJSON format for provinces/territories in `pt.geojson` and for health regions in `health_regions.geojson`. The map files are derived from TopoJSON files available from the [Public Health Agency of Canada's daily epidemiology update](https://health-infobase.canada.ca/covid-19/epidemiological-summary-covid-19-cases.html): [Can_PR2016.json](https://health-infobase.canada.ca/src/json/Can_PR2016.json) and [health-regions-2022.json](https://health-infobase.canada.ca/src/json/health-regions-2022.json), respectively. Both map files use the NAD83 / Statistics Canada Lambert projection ([EPSG:3347](https://epsg.io/3347)). Unprojected versions of the map files using WGS84 ([EPSG:4326](https://epsg.io/4326)) are available as `pt_wgs84.geojson` and `health_regions_wgs84.geojson`.

Note that the map files do not contain detailed name and population data. However, these data may be added by joining `pt.csv` or `health_regions.csv`.

## Health regions

Health region names and unique identifiers (UIDs) were derived from the [2018 cartographic boundary files for health regions](https://www150.statcan.gc.ca/n1/pub/82-402-x/2018001/hrbf-flrs-eng.htm) provided by Statistics Canada. The following changes were made to reflect updates to health region bounaries and to match the geography used by the province/territory to report COVID-19 data:

* Renamed Oxford Elgin St. Thomas Health Unit / Circonscription sanitaire d’Oxford, Elgin et St. Thomas (3575) to Southwestern Public Health Unit / Circonscription sanitaire du Sud-Ouest (3575)
* Removed Huron County Health Unit / Circonscription sanitaire du comté de Huron (3539) and Perth District Health Unit / Circonscription sanitaire du district de Perth (3554) and replaced with Huron Perth Public Health Unit / Circonscription sanitaire de Huron et Perth (3539)
* Replaced British Columbia's 16 Health Service Delivery Areas (5911, 5912, 5913, 5914, 5921, 5922, 5923, 5931, 5932, 5933, 5941, 5942, 5943, 5951, 5952, 5953) with the 5 amalgamated Regional Health Authorities (591, 592, 593, 594, 595)
* Replaced Saskatchewan's 13 Regional Health Authorities (4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713) with the 13 new zones (4711, 4712, 4713, 4721, 4722, 4723, 4731, 4732, 4741, 4751, 4761, 4762, 4763); note that these UIDs were created by appending a fourth, incrementing digit to the end of the previous 6 amalgamated zones (471, 472, 473, 474, 475, 476)

## Population data

Population data for both provinces/territories and health regions are available for various time periods in columns beginning with `pop_`. The canonical population (i.e., the most recent population available for a particular geography) is found in the column `pop`.

### Provinces/territories

Quarterly population estimates for provinces/territories were obtained from Statistics Canada [Table 17-10-0009-01 Population estimates, quarterly](https://doi.org/10.25318/1710000901-eng).

### Health regions

Mid-year annual population estimates for health regions (excluding Saskatchewan) were obtained from Statistics Canada [Table 17-10-0134-01 Estimates of population (2016 Census and administrative data), by age group and sex for July 1st, Canada, provinces, territories, health regions (2018 boundaries) and peer groups](https://doi.org/10.25318/1710013401-eng). Population estimates for British Columbia's 5 Regional Health Authorities were created by aggregating the values for the constituent 16 Health Service Delivery Areas.

For Saskatchewan's new 13 zones, population estimates were obtained from the [saskatchewan.ca dashboard](https://dashboard.saskatchewan.ca/health-wellness). The exact time period represented by these estimates is unknown, although they appear to differ slightly from Statistics Canada's province-wide population estimate for Saskatchewan. For these reason, they appear only in the `pop` column.
