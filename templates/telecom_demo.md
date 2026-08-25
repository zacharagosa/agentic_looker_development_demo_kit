# Demo Scenario Template: Telecom & 5G Network Performance Analytics

## Business Context
Showcase how Looker and Jetski can build an end-to-end Telecom & 5G Network Analytics solution for a data analyst at a major telecommunications provider. This demo highlights subscriber growth, plan distribution, 5G network latency, dropped call rates, and Average Revenue Per User (ARPU).

---

## Pre-flight Setup
- **Data Source**: Option A (Dynamic Agent-Generated Telecom Schema)
- **Target GCP Project**: `{your_argolis_gcp_project_id}`
- **Target BigQuery Dataset**: `demo_telecom_analytics`
- **Looker Connection**: `{your_looker_bq_connection_name}`
- **Looker Project**: `telecom_network_analytics`
- **Pre-Call Preparation**: Pre-fill this template outline with baseline assumptions ahead of the call. Walk through it with the customer at the start of the call to confirm the approach and make any adjustments on the fly.

---

## 🚀 Copy-Paste Live Demo Prompt for Jetski Web

Copy and paste the exact prompt below into **Jetski Web** during a customer call:

> "Jetski, we are building a live Telecom & 5G Network Performance solution for a data analyst at a major **Telecommunications Provider**.
> 
> Please execute the following end-to-end workflow:
> 
> 1. **Design a multi-table relational telecom schema** for the following 4 entities:
>    - `subscribers` (primary_key: `subscriber_id`, `first_name`, `last_name`, `email`, `plan_type` [5G Premium, 5G Unlimited, Standard Family, Prepaid], `account_status` [Active, Active, Active, Cancelled], `city`, `state`, `created_at`)
>    - `cell_towers` (primary_key: `tower_id`, `tower_name`, `region` [AMER-East, AMER-West, AMER-Central], `technology` [5G Ultra Capacity, 5G Extended Range, 4G LTE], `capacity_gbps`, `created_at`)
>    - `network_usage_logs` (primary_key: `log_id`, foreign_key: `subscriber_id`, foreign_key: `tower_id`, `data_usage_gb`, `voice_minutes`, `dropped_call_count`, `avg_latency_ms`, `log_timestamp`)
>    - `billing_statements` (primary_key: `statement_id`, foreign_key: `subscriber_id`, `plan_fee`, `overage_fee`, `total_amount`, `payment_status` [Paid, Paid, Overdue], `statement_date`)
> 
> 2. **Generate synthetic data and ingest into BigQuery**:
>    - Generate realistic CSV data for all 4 tables.
>    - Create BigQuery dataset `demo_telecom_analytics` under project `{your_argolis_gcp_project_id}` and load the CSV tables with auto-detected schemas.
> 
> 3. **Build LookML Views & Semantic Layer**:
>    - Create LookML view files for all 4 tables.
>    - Declare primary keys, dimensions, and the following key measures:
>      - `total_data_usage_tb` (`sum(data_usage_gb) / 1024`)
>      - `total_subscribers` (`count(distinct subscriber_id)`)
>      - `average_arpu` (`sum(total_amount) / count(distinct subscriber_id)`)
>      - `total_dropped_calls` (`sum(dropped_call_count)`)
>      - `avg_network_latency` (`avg(avg_latency_ms)`)
> 
> 4. **Create Model & Validate**:
>    - Create model file `telecom_analytics.model.lkml` joining `subscribers`, `network_usage_logs`, `cell_towers`, and `billing_statements`.
>    - Map the connection `{your_looker_bq_connection_name}`.
>    - Run LookML validation (`validate_project`) and execute a test query to guarantee zero errors, and deploy the project to production.
> 
> 5. **Generate Looker Dashboard**:
>    - Create a LookML dashboard `telecom_network_overview` featuring KPIs for Total Data Usage (TB), Active Subscribers, ARPU, Latency by 5G Technology, and Top Regions by Dropped Calls.
>    - Import it as a User-Defined Dashboard (UDD) in Looker, ensure all changes are deployed to production, and return the live URL."

---

## 🎙️ CE Presentation Narrative (What to Say While Jetski Builds)

- **Step 1: Schema Creation & BQ Load**:
  > *"Notice how Jetski designs a normalized telecom schema—subscribers, cell towers, network performance logs, and billing. It generates synthetic data and populates BigQuery dataset `demo_telecom_analytics` automatically."*

- **Step 2: Semantic Layer & Metrics**:
  > *"For a telecom analyst, consistency is critical. Looker's semantic layer centralizes calculations like ARPU and Data Usage in TB so every executive sees the exact same metrics without conflicting SQL scripts."*

- **Step 3: Zero-Error Verification**:
  > *"Jetski calls Looker's compiler to validate syntax and executes inline test queries to ensure zero SQL runtime errors before publishing."*

---

## 💡 Live Customer Challenge & Iteration Examples

Once the Looker dashboard URL opens in your browser, ask the customer:
> *"What additional telecom metric or visual breakdown would you like to see added?"*

#### Recommended Live Edit Prompts:
- **Challenge 1 (5G Performance Comparison)**:
  > *"Jetski, add a column chart comparing average network latency between 5G Ultra Capacity and 4G LTE."*
- **Challenge 2 (Churn Risk Filter)**:
  > *"Jetski, add a measure for Churn Rate and add a visual filter for Plan Type."*
