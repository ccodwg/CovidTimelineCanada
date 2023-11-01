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

### SK

Sourced from Saskatchewan's [weekly COVID-19 reports](https://publications.saskatchewan.ca/#/categories/5688) (archive UUID: `2b3954e7-a659-4555-b02e-3fcc4b1f0960`), which covered the period between 2022-01-23 and 2022-06-29. The following columns are included:

- `active_hospitalizations`: Total COVID Hospitalized
- `active_icu`: Total COVID Adult ICU/ICU Surge
- `average_daily_new_hospitalizations_past_7_days`: Average Daily Admissions over past 7 days
- `hosp_covid_related_illness`: Total COVID Related Illness
- `hosp_incidental_infection`: Total Incidental COVID Infection
- `hosp_patient_under_investigation`: Total Undetermined
