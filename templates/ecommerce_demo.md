# Demo Scenario Template: E-Commerce & Retail Analytics (using `looker-private-demo`)

## Business Context
Showcase how Looker can transform raw e-commerce order logs and customer profiles into real-time operational insights, revenue trends, and customer cohort analytics using the standard `looker-private-demo` BigQuery dataset.

## Pre-flight Setup
- **BigQuery Data Source**: Project `looker-private-demo`, Dataset `ecom` (or `thelook`)
- **Looker Connection**: `{your_looker_connection_name}` (connected to `looker-private-demo` or Argolis BQ)
- **Looker Project**: `agentic_ecommerce_demo`

## Prompt to Copy-Paste into Jetski during Live Demo
> "Jetski, we are doing a live demonstration of Looker's agentic coding capabilities using the standard `looker-private-demo` BigQuery project dataset `ecom`.
> 
> Please explore the dataset `looker-private-demo:ecom`, build LookML view files for all tables with proper primary keys and metrics (Total Revenue, Order Count, Average Order Value, Gross Margin), define an Explore with appropriate joins, validate the project, and create a LookML Sales Dashboard imported as a UDD in Looker."

## Key Metrics to Showcase Live
1. **Total Gross Revenue** (`sum(sale_price)`)
2. **Total Orders** (`count(distinct order_id)`)
3. **Average Order Value (AOV)** (`Total Revenue / Total Orders`)
4. **Order Status Distribution** (Complete vs Cancelled vs Returned)
5. **Top Product Categories by Revenue**

## Audience Engagement & Live Iteration Questions
After the initial dashboard is generated live, turn to the customer and ask:
- *"Would you like to see how easy it is to add a Customer Lifetime Value (CLV) calculation or customer cohort analysis?"*
- *"Should we add a visual filter for Order Status or Traffic Source?"*
- *"What happens if we want to change this table into a stacked column chart grouped by Brand?"*
