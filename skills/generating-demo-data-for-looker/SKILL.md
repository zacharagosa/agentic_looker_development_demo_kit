---
name: generating-demo-data-for-looker
description: >-
  Generates synthetic relational demo data (for ANY custom industry schema), utilizes standard public `looker-private-demo` BigQuery datasets, or ingests customer sample CSV files prior to LookML development.
---

# Data Discovery & Ingestion for Looker Live Demos

This skill enables the agent to acquire or generate demo data from **four flexible data sources**:
1. **Mode A (Dynamic Custom Schema)**: Generate synthetic CSV data on the fly for any custom industry schema (e.g. via `scripts/generate_demo_data.py --scenario fiber_telecom | ecommerce | saas`).
2. **Mode B (Standard `looker-private-demo` BQ Project)**: Utilize pre-existing datasets in the public `looker-private-demo` GCP project (e.g. `ecom`, `thelook`, `saas`, `retail`).
3. **Mode C (Customer CSV Ingestion)**: Ingest sample CSV files provided by the customer.
4. **Mode D (Native BigQuery In-Database SQL Generation)**: Generate massive synthetic datasets (thousands to millions of rows) directly inside BigQuery using SQL (`GENERATE_ARRAY()`, `FARM_FINGERPRINT()`, `ST_GEOGPOINT()`), bypassing local disk/bandwidth bottlenecks.

---

## Instructions

### Step 1: Identify Data Source Mode

Determine from the CE's prompt which data source mode to execute:

#### Mode A: Dynamic Custom Industry Schema
Use when the customer asks for a custom domain (e.g., *Enterprise Fiber Telecom*, *Logistics*, *Gaming*, *Real Estate*).
1. Execute the synthetic generator script:
   ```bash
   # Example: Built-in Enterprise Fiber & Telecom Infrastructure scenario
   python3 scripts/generate_demo_data.py \
     --scenario fiber_telecom \
     --output-dir /tmp/demo_fiber_data
   ```
2. Load into BigQuery:
   ```bash
   bq mk --dataset {gcp_project}:{dataset_name}
   for csv_file in /tmp/demo_fiber_data/*.csv; do
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

#### Mode D: Native BigQuery In-Database SQL Generation
Use when presenting massive scale, sub-second live ingestion, or high-cardinality telemetry (100k+ rows) directly inside BigQuery without local CSV file I/O.
1. Create dataset and run in-database generation SQL using `bq query`:
   ```sql
   CREATE OR REPLACE TABLE `{gcp_project}.{dataset_name}.optical_telemetry_logs` AS
   SELECT
     i AS log_id,
     MOD(ABS(FARM_FINGERPRINT(CONCAT('SPAN-', i))), 35) + 1 AS span_id,
     CONCAT('CKT-400G-', LPAD(CAST(MOD(ABS(FARM_FINGERPRINT(CONCAT('CKT-', i))), 120) + 1 AS STRING), 4, '0')) AS circuit_id,
     ROUND(-15.0 - (RAND() * 12.0), 2) AS rx_optical_power_dbm,
     ROUND(0.5 + (RAND() * 2.5), 2) AS tx_optical_power_dbm,
     ROUND(300.0 + (RAND() * 1200.0), 1) AS chromatic_dispersion_ps_nm,
     ROUND(16.0 + (RAND() * 14.0), 1) AS optical_snr_db,
     ROUND(24.0 + (RAND() * 20.0), 1) AS temperature_c,
     TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL CAST(RAND() * 2592000 AS INT64) SECOND) AS log_timestamp
   FROM UNNEST(GENERATE_ARRAY(1, 100000)) AS i;
   ```
2. This creates 100,000 fully distributed optical telemetry records in under 3 seconds directly within BigQuery!

---

### Step 2: Hand Off to LookML Generator
Summarize the dataset tables, schemas, primary keys, and foreign key relationships, then proceed to `creating-lookml-model`.
