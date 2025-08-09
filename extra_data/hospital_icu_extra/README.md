## Extra hospital/ICU data

This dataset contains extra hospital/ICU occupancy and admission data that are not included in the main hospital/ICU occupancy and admission datasets. This mainly consists of data distinguishing hospital occupancy or admissions "for" or "with" COVID-19, whenever such distinctions were made in the source dataset.

The exact meaning and sources of each column is described below:

### AB

Sourced from Alberta's COVID-19 summary statistics dataset (archive UUID: `3ced816d-8524-4875-bd69-61fb5603b596`), the province reported hospital/ICU occupancy "for" and "with" COVID-19 separately between 2022-02-01 and 2023-08-21.

The following columns are included:

- `ab_hosp_occupancy_for_with`: Hospital occupancy "for" and "with" COVID-19
- `ab_hosp_occupancy_for`: Hospital occupancy "for" COVID-19
- `ab_icu_occupancy_for_with`: ICU occupancy "for" and "with" COVID-19
- `ab_icu_occupancy_for`: ICU occupancy "for" COVID-19

### MB

There are two datasets for Manitoba.

### Active and non-infectious

The first dataset is sourced from Manitoba's [COVID-19 dashboard](https://experience.arcgis.com/experience/f55693e56018406ebbd08b3492e99771) (archive UUID: `8cb83971-19f0-4dfc-b832-69efc1036ddd`), where the province distinguished hospital/ICU occupancy for cases with active COVID-19 and those no longer infectious but still requiring care (this is **not** the same thing as "for" and "with" COVID-19). An [example of the language used](https://web.archive.org/web/20220107184243/https://news.gov.mb.ca/news/index.html?item=53158&posted=2022-01-07) is as follows:

> - 297 Manitobans hospitalized with COVID-19 including 257 people with active COVID-19 as well as 40 people who are no longer infectious;
> - a total of 34 Manitoba patients receiving intensive care for COVID-19 including 33 people in intensive care units with active COVID-19 as well as one person who is no longer infectious but continue to require critical care

These data were reported on Manitoba's dashboard between 2021-02-04 and 2022-03-25. Earlier data reporting the same values can be found in Manitoba's [COVID-19 bulletins](https://news.gov.mb.ca/news/index.html?item=50563) but has not been added to this dataset.

The following columns are included:

- `mb_hosp_occupancy_active_and_non_infectious`: Total hospital occupancy (this is the standard value reported in the main dataset)
- `mb_hosp_occupancy_active`: Hospital occupancy with active COVID-19, as defined above
- `mb_icu_occupancy_active_and_non_infectious`: Total ICU occupancy (this is the standard value reported in the main dataset)
- `mb_icu_occupancy_active`: ICU occupancy with active COVID-19, as defined above

This dataset considers only ICU occupancy within the province. See the second dataset below for out-of-province ICU occupancy for Manitoba residents.

### In-province and out-of-province

Sourced from Manitoba's [COVID-19 bulletins](https://news.gov.mb.ca/news/?archive=&item=51383), the province reported ICU occupancy in- and out-of-province between 2021-06-04 and 2021-07-16 (although out-of-province ICU occupancy clearly began prior to this date). In the main dataset, we report only in-province ICU occupancy.

The following columns are included:

- `mb_hosp_occupancy_in_province`: Hospital occupancy within Manitoba
- `mb_icu_occupancy_in_province`: ICU occupancy within Manitoba
- `mb_icu_occupancy_out_of_province`: ICU occupancy of Manitoba residents outside of Manitoba (reported between 2021-06-04 and and 2021-07-16)
- `mb_hosp_occupancy_total`: Sum of `mb_hosp_occupancy_in_province` and `mb_icu_occupancy_out_of_province` (reported between 2021-06-04 and 2021-07-16)
- `mb_icu_occupancy_total`: Sum of `mb_icu_occupancy_in_province` and `mb_icu_occupancy_out_of_province` (reported between 2021-06-04 and 2021-07-16)

### NB

The [New Brunswick dashboard](https://experience.arcgis.com/experience/8eeb9a2052d641c996dba5de8f25a8aa) (archive UUID: `4f194e3b-39fd-4fe0-b420-8cefa9001f7e`), for a period, decomposed hospital/ICU occupancy "for" and "with" COVID-19, as well as reporting COVID-19 admission totals (which were not included in the main dataset, as they disagreed with later cumulative values).

The following columns are included:

- `nb_hosp_occupancy_for_with`: Hospital occupancy "for" and "with" COVID-19
- `nb_hosp_occupancy_for`: Hospital occupancy "for" COVID-19
- `nb_icu_occupancy_for_with`: ICU occupancy "for" and "with" COVID-19
- `nb_icu_occupancy_for`: ICU occupancy "for" COVID-19
- `nb_total_hosp_admissions`: Total hospital admissions (note that this number is much higher than the cumulative totals later given in the NB's weekly reports, so these values were not included in the main dataset; this may be due to a "for" and "with" distinction)
- `nb_total_hosp_discharged`: Total discharged from hospital

### PE

The PEI COVID-19 [news releases](https://www.princeedwardisland.ca/en/search/site?f%5B0%5D=type%3Anews&f%5B1%5D=field_news_type%3A22&f%5B2%5D=field_department%3A612) and [data webpage](https://www.princeedwardisland.ca/en/information/health-and-wellness/covid-19-testing-and-case-data) (archive UUIDs: `fff9248e-fa24-4efb-ae04-000f3e5c815f` and `68e5cbb9-0dcc-4a4f-ade0-58a0b06b1455`) decomposed hospital occupancy "for" and "with" COVID-19 between 2021-12-31 and 2022-11-08. ICU occupancy was presented as a subset of hospital occupancy "for" COVID-19. The following columns are included:

- `pe_hosp_occupancy_for`: Hospital occupancy "for" COVID-19
- `pe_hosp_occupancy_with`: Hospital occupancy "with" COVID-19
- `pe_icu_occupancy`: ICU occupancy (subset of hospital occupancy "for" COVID-19)

Occasionally, the number of patients in hospital "with" COVID-19 was not given and is thus missing from the dataset. The definitions given for individuals "with" COVID-19 were as follows: "individuals in hospital for other reasons who have tested positive for COVID-19" and "admitted for other reasons and were COVID-19 positive on or after admission".

### QC

The [INSPQ dashboard](https://www.inspq.qc.ca/covid-19/donnees) (archive UUID: `3b93b663-4b3f-43b4-a23d-cbf6d149d2c5`) decomposed hospital/ICU admissions "for" and "with" COVID-19 between 2020-01-24 and 2023-11-29. The following columns are included:

- `qc_hosp_admissions_for_with`: Hospital admissions "for" and "with" COVID-19
- `qc_hosp_admissions_for`: Hospital admissions "for" COVID-19
- `qc_hosp_admissions_with`: Hospital admissions "with" COVID-19
- `qc_icu_admissions_for_with`: ICU admissions "for" and "with" COVID-19
- `qc_icu_admissions_for`: ICU admissions "for" COVID-19
- `qc_icu_admissions_with`: ICU admissions "with" COVID-19

According to the original data notes, admissions with unknown status are included in the "with" category. The most recent days of data, particularly the most recent day of data, may be incomplete.

### SK

There are two datasets for Saskatchewan.

### For, with, not yet determined (dashboard)

The first dataset is sourced from Saskatchewan's [COVID-19 dashboard](https://dashboard.saskatchewan.ca/health-wellness/covid-19-cases/hospitalized) (archive UUID: `6e5dd7b2-c6b8-4fd0-8236-ef34873233d2`), which decomposed COVID-19 hospital and ICU occupancy in the period between 2022-01-06 and 2022-02-06. The following columns are included:

- `sk_dash_hosp_occupancy_total`: Total hospital occupancy related to COVID-19
- `sk_dash_inpatient_occupancy_total`: Total inpatient occupancy related to COVID-19 (the sum of `sk_dash_inpatient_occupancy_covid_related_illness`, `sk_dash_inpatient_occupancy_incidental_infection`, and `sk_dash_inpatient_occupancy_patient_under_investigation`)
- `sk_dash_inpatient_occupancy_covid_related_illness`: Of total inpatient occupancy related to COVID-19, those hospitalized "for" COVID-19
- `sk_dash_inpatient_occupancy_incidental_infection`: Of total inpatient occupancy related to COVID-19, those hospitalized "with" COVID-19
- `sk_dash_inpatient_occupancy_not_yet_determined`: Of total inpatient occupancy related to COVID-19, those with status not yet determined
- `sk_dash_icu_occupancy_total`: Total ICU occupancy related to COVID-19 (the sum of `sk_dash_icu_occupancy_covid_related_illness`, `sk_dash_icu_occupancy_incidental_infection`, and `sk_dash_icu_occupancy_not_yet_determined`)
- `sk_dash_icu_occupancy_covid_related_illness`: Of total ICU occupancy related to COVID-19, those hospitalized "for" COVID-19
- `sk_dash_icu_occupancy_incidental_infection`: Of total ICU occupancy related to COVID-19, those hospitalized "with" COVID-19
- `sk_dash_icu_occupancy_not_yet_determined`: Of total ICU occupancy related to COVID-19, those with status not yet determined
- `sk_dash_picu_nicu_occupancy_total`: Total pediatric ICU and neonatal ICU occupancy related to COVID-19
- `sk_dash_picu_nicu_occupancy_covid_related_illness`: Of total pediatric ICU and neonatal ICU occupancy related to COVID-19, those hospitalized "for" COVID-19
- `sk_dash_picu_nicu_occupancy_incidental_infection`: Of total pediatric ICU and neonatal ICU occupancy related to COVID-19, those hospitalized "with" COVID-19
- `sk_dash_picu_nicu_occupancy_not_yet_determined`: Of total pediatric ICU and neonatal ICU occupancy related to COVID-19, those with status not yet determined

Note that the `sk_dash_icu_occupancy_total` seems to include pediatric ICU and neonatal ICU occupancy between 2022-01-23 and 2022-01-30 and between 2022-02-01 and 2022-02-02 (i.e., during these periods, `sk_dash_icu_occupancy_total` is the sum of `sk_dash_icu_occupancy_covid_related_illness`, `sk_dash_icu_occupancy_incidental_infection`, `sk_dash_icu_occupancy_not_yet_determined`, and `sk_dash_picu_nicu_occupancy_total`), but these values seem to be reported separately during other dates.

### For, with, under investigation (weekly reports)

The second dataset is sourced from Saskatchewan's [weekly COVID-19 reports](https://publications.saskatchewan.ca/#/categories/5688) (archive UUID: `2b3954e7-a659-4555-b02e-3fcc4b1f0960`), which covered the period between 2022-02-02 and 2022-06-29. The following columns are included:

- `sk_rep_hosp_occupancy_total`: Total hospital occupancy related to COVID-19 (the sum of `sk_rep_hosp_occupancy_covid_related_illness`, `sk_rep_hosp_occupancy_incidental_infection`, and `sk_rep_hosp_occupancy_patient_under_investigation`)
- `sk_rep_hosp_occupancy_covid_related_illness`: Of total hospital occupancy related to COVID-19, those hospitalized "for" COVID-19
- `sk_rep_hosp_occupancy_incidental_infection`: Of total hospital occupancy related to COVID-19, those hospitalized "with" COVID-19
- `sk_rep_hosp_occupancy_patient_under_investigation`: Of total hospital occupancy related to COVID-19, those of undetermined status
- `sk_rep_icu_occupancy_total`: Total adult ICU/ICU surge occupancy related to COVID-19
- `sk_rep_hosp_admissions_daily_avg_past_7_days`: Average daily hospital admissions related to COVID-19 over the past 7 days

Note that on 2022-03-09, there is a discrepancy between `sk_rep_hosp_occupancy_total` and the sum of its three constituent columns (339 vs. 340).
