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

Sourced from Saskatchewan's [weekly COVID-19 reports](https://publications.saskatchewan.ca/#/categories/5688) (archive UUID: `2b3954e7-a659-4555-b02e-3fcc4b1f0960`), which covered the period between 2022-02-02 and 2022-06-29. The following columns are included:

- `sk_hosp_occupancy_total`: Total hospital occupancy related to COVID-19 (the sum of `sk_hosp_occupancy_covid_related_illness`, `sk_hosp_occupancy_incidental_infection`, and `sk_hosp_occupancy_patient_under_investigation`)
- `sk_hosp_occupancy_covid_related_illness`: Of total hospital occupancy related to COVID-19, those hospitalized "for" COVID-19
- `sk_hosp_occupancy_incidental_infection`: Of total hospital occupancy related to COVID-19, those hospitalized "with" COVID-19
- `sk_hosp_occupancy_patient_under_investigation`: Of total hospital occupancy related to COVID-19, those of undetermined status
- `sk_icu_occupancy`: Total adult ICU/ICU surge occupancy related to COVID-19
- `sk_hosp_admissions_daily_avg_past_7_days`: Average daily hospital admissions related to COVID-19 over the past 7 days

Note that on 2022-03-09, there is a discrepancy between `sk_hosp_occupancy_total` and the sum of its three constituent columns (339 vs. 340).
