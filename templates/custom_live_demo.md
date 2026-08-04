# Demo Scenario Template: Custom On-the-Fly Customer Requirements

## Purpose
Use this template when presenting to a customer who wants to see their own specific industry domain, multi-table schema, or business questions built live in real time.

---

## 1. Data Source Selection Options for the CE

Before prompting Jetski, choose **where the demo data will come from**:

| Data Source Mode | Description | Prompt Directive to Include |
| :--- | :--- | :--- |
| **Option A: Dynamic Agent-Generated Data** *(Recommended for custom requests)* | Agent designs a custom multi-table relational schema for any industry on the fly | *"Jetski, design a custom multi-table relational schema for the [{Industry}] domain and generate synthetic data into BigQuery..."* |
| **Option B: Standard `looker-private-demo` BQ Datasets** *(Fastest & Curated)* | Utilize pre-existing curated demo datasets in Google's `looker-private-demo` GCP project (e.g. `ecom`, `thelook`, `retail`, `saas`, `financial`) | *"Jetski, use the `looker-private-demo` BigQuery project dataset `ecom` (or `thelook`, `saas`, `retail`). Explore the dataset, build LookML views, model file, and dashboard..."* |
| **Option C: Customer-Provided Sample CSV Files** | Customer brought sample CSV files to the meeting | *"Jetski, load the sample CSV files located at `/path/to/customer/csvs/*.csv` into BigQuery dataset `demo_customer`..."* |

---

## 2. Pre-Meeting Preparation & Live Confirmation
1. **Pre-Meeting Preparation (Ahead of Call)**:
   - Draft an initial outline of your prompt template with a baseline approach and assumed entities/KPIs for the customer's domain so you come to the meeting prepared.
2. **Live Customer Confirmation (Start of Call)**:
   - Walk through your pre-filled prompt outline with the customer at the start of the call to confirm the approach:
     - *"We prepared this baseline outline for [Industry/Domain] focusing on [Entities] and [KPIs]. Does this align with what your team wants to see today?"*
     - *"Are there any specific adjustments or additional metrics you'd like us to change in this template before we kick it off?"*
3. **Adjust on the Fly**:
   - Make any live edits to the template based on customer feedback before submitting to Jetski.

---

## 3. Live Prompt Builder Templates for Jetski

### Prompt Example for Option B (`looker-private-demo` BQ Project):

> "Jetski, we are doing a live Looker demo using the standard `looker-private-demo` BigQuery project.
> 
> **Data Source**: Option B (`looker-private-demo`)
> - **GCP Project**: `looker-private-demo`
> - **Dataset**: `ecom` (or `thelook`, `saas_analytics`, `retail`)
> - **Target KPIs**: Total Sales, Order Volume, Average Order Value, Top Categories
> 
> Please perform the following end-to-end workflow:
> 1. Explore tables and column schemas in `looker-private-demo:{dataset}` using `bq`.
> 2. Create LookML view files for all tables with primary keys, dimensions, and measures.
> 3. Create a model file joining the tables on foreign keys.
> 4. Validate LookML code and run a verification query.
> 5. Build an executive LookML dashboard and import it as a Looker User Defined Dashboard (UDD)."

---

## 4. Live Iteration Strategies
Once the initial dashboard opens in Looker, invite the customer to challenge the agent:
- *"Give me your hardest calculation or chart modification, and watch Jetski rewrite the LookML in real time."*
- Example live prompt: *"Jetski, add a 7-day moving average measure and a stacked column chart grouped by region."*
