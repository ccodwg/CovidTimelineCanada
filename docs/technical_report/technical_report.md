# Timeline of COVID-19 in Canada: Technical report


## Metrics in this dataset

The following table describes 1) the short and long names of the metrics
in this dataset, 2) for each metric, the definition of “value” and
“daily value”, and 3) the source of the values for each geographic level
(health region-level, HR; province/territory-level, PT; Canada-level,
CAN). For example, for cases, the the PT-level and and CAN-level values
are aggregated from the HR-level values, whereas CAN-level vaccine
coverage data are not aggregated from PT-level values, but is actually
an independent dataset. For case and death data, there a few exceptions
where the PT-level values are not aggregated from the HR-level values
these are listed below the table.

| Metric | Description | HR | PT | CAN |
|:---|:---|:---|:---|:---|
| `cases` (Cases) | **Value**: The cumulative number of COVID-19 cases reported up to a given day.<br>**Daily value**: The change in the number of COVID-19 cases compared to the previous day. | HR | HR | HR |
| `deaths` (Deaths) | **Value**: The cumulative number of COVID-19 deaths reported up to a given day.<br>**Daily value**: The change in the number of COVID-19 deaths compared to the previous day. | HR | HR | HR |
| `hospitalizations` (Active hospitalizations) | **Value**: The number of active hospitalizations related to COVID-19 (non-ICU and ICU) reported for a given day.<br>**Daily value**: The change in the number of active hospitalizations related to COVID-19 compared to the previous day. | N/A | PT | CAN |
| `icu` (Active ICU) | **Value**: The number of active ICU hospitalizations related to COVID-19 reported for a given day.<br>**Daily value**: The change in the number of active ICU hospitalizations related to COVID-19 compared to the previous day. | N/A | PT | CAN |
| `hosp_admissions` (Hospital admissions) | **Value**: The cumulative number of hospital admissions (non-ICU and ICU) related to COVID-19 reported up to a given day.<br>**Daily value**: The change in the number of hospital admissions related to COVID-19 compared to the previous day. | N/A | PT | N/A |
| `icu_admissions` (ICU admissions) | **Value**: The cumulative number of ICU admissions related to COVID-19 reported up to a given day.<br>**Daily value**: The change in the number of ICU admissions related to COVID-19 compared to the previous day. | N/A | PT | N/A |
| `tests_completed` (Tests completed) | **Value**: The cumulative number of PCR tests for COVID-19 reported up to a given day.<br>**Daily value**: The change in the number of PCR tests for COVID-19 reported compared to the previous day. | N/A | PT | PT |
| `vaccine_coverage_dose_1` (Vaccine coverage (dose 1)) | **Value**: The cumulative percent coverage of first doses of COVID-19 vaccines in the population reported up to a given day.<br>**Daily value**: The change in the percent coverage of first doses of COVID-19 vaccines reported compared to the previous day. | N/A | PT | CAN |
| `vaccine_coverage_dose_2` (Vaccine coverage (dose 2)) | **Value**: The cumulative percent coverage of second doses of COVID-19 vaccines in the population reported up to a given day.<br>**Daily value**: The change in the percent coverage of second doses of COVID-19 vaccines reported compared to the previous day. | N/A | PT | CAN |
| `vaccine_coverage_dose_3` (Vaccine coverage (dose 3)) | **Value**: The cumulative percent coverage of third doses of COVID-19 vaccines in the population reported up to a given day.<br>**Daily value**: The change in the percent coverage of third doses of COVID-19 vaccines reported compared to the previous day. | N/A | PT | CAN |
| `vaccine_coverage_dose_4` (Vaccine coverage (dose 4)) | **Value**: The cumulative percent coverage of fourth doses of COVID-19 vaccines in the population reported up to a given day.<br>**Daily value**: The change in the percent coverage of fourth doses of COVID-19 vaccines reported compared to the previous day. | N/A | PT | CAN |
| `vaccine_administration_total_doses` (Vaccine administration (total doses)) | **Value**: The cumulative number of total doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of total doses of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_administration_dose_1` (Vaccine administration (dose 1)) | **Value**: The cumulative number of first doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of first doses of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_administration_dose_2` (Vaccine administration (dose 2)) | **Value**: The cumulative number of second doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of second doses of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_administration_dose_3` (Vaccine administration (dose 3)) | **Value**: The cumulative number of third doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of third doses of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_administration_dose_4` (Vaccine administration (dose 4)) | **Value**: The cumulative number of fourth doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of fourth doses of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_administration_dose_5plus` (Vaccine administration (dose 5+)) | **Value**: The cumulative number of fifth or greater doses of COVID-19 vaccines administered reported up to a given day.<br>**Daily value**: The change in the number of fifth or greater doses more of COVID-19 vaccines administered reported compared to the previous day. | N/A | PT | PT |
| `vaccine_distribution_total_doses` (Vaccine distribution (total doses)) | **Value**: The cumulative number of total doses of COVID-19 vaccines distributed reported up to a given day.<br>**Daily value**: The change in the number of total doses of COVID-19 vaccines distributed reported compared to the previous day. | N/A | PT | CAN |

As mentioned above, some PT-level case and death data are not aggregated
from the HR-level values after a certain date. This is because the
available PT-level data is of significantly higher accuracy or temporal
resolution and better reflects the true number of cases and deaths if
sub-provincial geographic resolution is not required. The following list
includes all such substitutions:

Case data:

- NB: 2022-12-17 onward
- SK: 2022-02-12 onward

Death data:

- AB: 2020-03-06 onward
- ON: 2020-03-01 onward
- SK: 2022-02-12 onward

For more details, see this [GitHub
issue](https://github.com/ccodwg/CovidTimelineCanada/issues/120).

### Hospital/ICU metrics

Hospital/ICU metrics (occupancy and admissions) may report the number
“for” COVID-19 or combined numbers (both “for” and “with” COVID-19), but
the number “for” COVID-19 is reported preferentially, if more than one
number is available. Often, only one number is reported, and which
number it is may differ over time. Metadata will be added to distinguish
where this occurs. An extra dataset will also be added to included the
decomposed hospital/ICU numbers, where available.

In cases where hospital/ICU admissions are reported cumulatively but the
time series does not start at the beginning, the first “daily value”
will be censored as to not imply that the entire cumulative count was
reported on a single day.

An alternative Canada-wide COVID-19 hospital and ICU admissions dataset
is available from CIHI
[here](https://www.cihi.ca/en/covid-19-hospitalization-and-emergency-department-statistics).
