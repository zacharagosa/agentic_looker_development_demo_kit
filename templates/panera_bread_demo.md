# Demo Scenario Template: Panera Bread Fast-Casual Restaurant & Loyalty Analytics

## Business Context
Showcase how Looker and Agentic AI can build an end-to-end Fast-Casual Restaurant Analytics solution for a data analyst or regional operations manager at **Panera Bread**. This demo highlights omnichannel sales (Rapid Pick-Up, Drive-Thru, Kiosk, Mobile App), MyPanera loyalty engagement, Unlimited Sip Club subscription impacts, menu category performance (Soups, Sandwiches, Bakery), and cafe order preparation speed.

---

## Pre-flight Setup
- **Data Source**: Option A (Dynamic Agent-Generated Panera Bakery-Cafe Schema)
- **Target GCP Project**: `{your_argolis_gcp_project_id}`
- **Target BigQuery Dataset**: `demo_panera_bread`
- **Looker Connection**: `{your_looker_bq_connection_name}`
- **Looker Project**: `panera_bread_analytics`

---

## 🚀 Copy-Paste Live Demo Prompt for Jetski Web

Copy and paste the exact prompt below into **Jetski Web** during a customer call:

> "Jetski, we are building a live Fast-Casual Restaurant & Loyalty Analytics solution for a regional operations analyst at **Panera Bread**.
> 
> Please execute the following end-to-end workflow:
> 
> 1. **Design a multi-table relational restaurant & loyalty schema** for the following 5 entities:
>    - `cafes` (primary_key: `cafe_id`, `store_number`, `cafe_name`, `city`, `state`, `region` [Northeast, Midwest, South, West], `store_type` [Corporate, Franchise], `has_drive_thru` [true, false])
>    - `mypanera_members` (primary_key: `member_id`, `first_name`, `last_name`, `email`, `sip_club_subscriber` [true, false], `membership_tier` [Gold, Member], `total_lifetime_visits`, `created_at`)
>    - `menu_items` (primary_key: `item_id`, `item_name`, `category` [Soups & Bowls, Sandwiches, Bakery & Pastries, Beverages, Salads], `cost`, `retail_price`, `calories`)
>    - `orders` (primary_key: `order_id`, foreign_key: `cafe_id`, foreign_key: `member_id`, `channel` [Mobile App, Rapid Pick-Up, Drive-Thru, In-Store Kiosk, Counter], `status` [Completed, Completed, Completed, Refunded], `prep_time_seconds`, `created_at`)
>    - `order_items` (primary_key: `order_item_id`, foreign_key: `order_id`, foreign_key: `item_id`, `quantity`, `sale_price`, `created_at`)
> 
> 2. **Generate synthetic data and ingest into BigQuery**:
>    - Generate realistic CSV data for all 5 tables (with popular Panera items like Broccoli Cheddar Soup, Frontega Chicken Sandwich, Charged Lemonade, Cinnamon Swirl Bagel).
>    - Create BigQuery dataset `demo_panera_bread` under project `{your_argolis_gcp_project_id}` and load the CSV tables with auto-detected schemas.
> 
> 3. **Build LookML Views & Semantic Layer**:
>    - Create LookML view files for all 5 tables.
>    - Declare primary keys, dimensions, and the following key measures:
>      - `total_gross_sales` (`sum(quantity * sale_price)`)
>      - `total_orders` (`count(distinct order_id)`)
>      - `average_order_value` (`total_gross_sales / total_orders`)
>      - `avg_prep_time_minutes` (`avg(prep_time_seconds) / 60.0`)
>      - `loyalty_order_percentage` (`count(distinct member_id) / total_orders * 100.0`)
>      - `sip_club_sales` (`sum(case when sip_club_subscriber then quantity * sale_price end)`)
> 
> 4. **Create Model & Validate**:
>    - Create model file `panera_bread.model.lkml` joining `orders`, `cafes`, `mypanera_members`, `order_items`, and `menu_items`.
>    - Map the connection `{your_looker_bq_connection_name}`.
>    - Run LookML validation (`validate_project`) and execute a test query to guarantee zero errors, and deploy the project to production.
> 
> 5. **Generate Looker Dashboard**:
>    - Create a LookML dashboard `panera_cafe_performance` featuring KPIs for Total Gross Sales, Order Volume, AOV, Avg Order Prep Time, Sales by Channel (Rapid Pick-Up vs Drive-Thru vs Mobile App), and Sales by Menu Category (Soups, Sandwiches, Bakery).
>    - Import it as a User-Defined Dashboard (UDD) in Looker, ensure all changes are deployed to production, and return the live URL."

---

## 🎙️ CE Presentation Narrative (What to Say While Jetski Builds)

- **Minute 2 (Schema Creation & BQ Load)**:
  > *"Notice how Jetski designs a normalized fast-casual restaurant schema—cafes, MyPanera loyalty members, menu items, order channels, and itemized line items. It generates synthetic transaction logs and populates BigQuery dataset `demo_panera_bread` in seconds."*

- **Minute 3 (Semantic Layer & Metrics)**:
  > *"For Panera, operational speed and loyalty revenue are critical. Looker's semantic layer centralizes calculations like Average Order Prep Time and Unlimited Sip Club Incremental Sales so store managers and executives view identical numbers."*

- **Minute 4 (Zero-Error Verification)**:
  > *"Jetski calls Looker's compiler to validate syntax and executes inline test queries to ensure zero SQL runtime errors before publishing."*

---

## 💡 Live Customer Challenge & Iteration Examples

Once the Looker dashboard URL opens in your browser, ask the Panera customer:
> *"What additional store operation, menu item, or loyalty metric would you like to see added?"*

#### Recommended Live Edit Prompts:
- **Challenge 1 (Sip Club Impact Analysis)**:
  > *"Jetski, add a bar chart comparing Average Order Value (AOV) between Unlimited Sip Club subscribers and non-subscribers."*
- **Challenge 2 (Fulfillment Speed by Channel)**:
  > *"Jetski, add a measure for Order Fulfillment Speed (in seconds) and group prep time by Order Channel (Rapid Pick-Up vs Drive-Thru vs Counter)."*
