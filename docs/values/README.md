# `values.json`: Definitions and data notes

The file [`values.json`](https://github.com/ccodwg/CovidTimelineCanada/blob/main/docs/values/values.json) contains definitions and data notes for each metric in the `CovidTimelineCanada` dataset.

The file uses the following structure:

```json
{
    "Metric name": {
        "name": "Metric name",
        "name_long": "Metric name (long)",
        "value": "Definition for 'value' for this metric.",
        "value_daily": "Definition for 'value_daily` for this metric.",
        "geo": {
            "can": "can",
            "pt": "hr",
            "hr": "hr"
        },
        "general_notes": "General notes pertaining to the use or definition of the metric.",
        "data_notes": {
            "can": [
                {
                    "date_start": "",
                    "date_end": "",
                    "note": "Note relating to the Canada-level dataset.",
                    "source": "URL supporting the note."
                }
            ],
            "ab": [
                {
                    "date_start": "2022-01-01",
                    "date_end": "2022-03-31",
                    "note": "Note relating to the dataset for Alberta.",
                    "source": "URL supporting the note."
                }
            ]
        }
    }
}
```

The `geo` section can contain up to three keys:

- `can`: If this key is present, a Canada-level dataset is available for this metric. The value is one of `can`, `pt`, `hr`, depending on which level of data are used to generate the Canada-level dataset. A value of `can` means the dataset is **not** simply an aggrgation of the province/territory or health region-level dataset; rather, a seperate Canada-level dataset is used.
- `pt`: If this key is present, a province/territory-level dataset is available for this metric. The value is one of `pt` or `hr`, depending on if the province/territory dataset is aggregated from a health region-level dataset.
- `ht`: If this key is present, a health region-level dataset is available for this metric. The value is `hr`.

Each entry in `data_notes` uses as a key either `can` (for a Canada-level dataset), `pt` (for a province/territory-level dataset), or a specific two-letter province/territory code (e.g., `ab`, for a note pertaining to a specific province/territory). The `date_start` and `date_end` fields indicate the range of data the note applies to. A blank value for `date_start` indicates the beginning of the dataset; a blank value for `date_end` indicates the end of the dataset. Entries may contain multiple data notes applying to different date ranges.
