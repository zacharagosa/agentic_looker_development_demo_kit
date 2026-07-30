---
name: generating-demo-data-for-looker
description: >-
  Generates synthetic relational demo data (for ANY custom industry schema), utilizes standard public `looker-private-demo` BigQuery datasets, or ingests customer sample CSV files prior to LookML development.
---

# Data Discovery & Ingestion for Looker Live Demos

This skill enables the agent to acquire or generate demo data from **three flexible data sources**:
1. **Mode A (Dynamic Custom Schema)**: Generate synthetic data on the fly for any custom industry schema.
2. **Mode B (Standard `looker-private-demo` BQ Project)**: Utilize pre-existing datasets in the public `looker-private-demo` GCP project (e.g. `ecom`, `thelook`, `saas`, `retail`).
3. **Mode C (Customer CSV Ingestion)**: Ingest sample CSV files provided by the customer.

---

## Instructions

### Step 1: Identify Data Source Mode

Determine from the CE's prompt which data source mode to execute:

#### Mode A: Dynamic Custom Industry Schema
Use when the customer asks for a custom domain (e.g., *Logistics*, *Healthcare Encounters*, *Gaming*, *Real Estate*).
1. Design a multi-table relational schema JSON (with primary keys, foreign keys, metrics, dimensions, timestamps).
2. Execute the synthetic generator script:
   ```bash
   python3 /usr/local/google/home/aragosa/.gemini/jetski/scratch/looker-ce-demo-kit/scripts/generate_demo_data.py \
     --output-dir /tmp/demo_data \
     --schema-json '{ ... JSON_STRING ... }'
   ```
3. Load into BigQuery:
   ```bash
   bq mk --dataset {gcp_project}:{dataset_name}
   for csv_file in /tmp/demo_data/*.csv; do
     tbl=$(basename "$csv_file" .csv)
     bq load --source_format=CSV --autodetect --skip_leading_rows=1 --replace "{gcp_project}:{dataset_name}.${tbl}" "$csv_file"
   done
   ```

#### Mode B: Standard `looker-private-demo` BigQuery Datasets
Use when the CE requests a standard demo dataset in `looker-private-demo` (e.g. `ecom`, `thelook`, `saas`, `retail`).
1. Explore tables and schemas directly in BigQuery:
   ```bash
   bq ls looker-private-demo:{dataset_name}
   ```
2. Inspect schema for primary/foreign keys:
   ```bash
   bq show --format=prettyjson looker-private-demo:{dataset_name}.{table_name}
   ```
3. Proceed directly to `creating-lookml-model` targeting `looker-private-demo:{dataset_name}`.

#### Mode C: Customer Sample CSV Files
Use when local CSV files are provided by the customer.
1. Load CSVs into the CE's target BigQuery dataset using `bq load`.

---

### Step 2: Hand Off to LookML Generator
Summarize the dataset tables, schemas, primary keys, and foreign key relationships, then proceed to `creating-lookml-model`.
