#!/usr/bin/env python3
"""
Synthetic Data Generator for Looker Agentic Development CE Demo Kit
Supports:
1. Built-in pre-packaged verticals (--scenario ecommerce | saas)
2. Dynamic multi-table schema generation (--schema-file PATH | --schema-json JSON_STRING)

No external dependencies required (uses Python standard library).
"""

import argparse
import csv
import datetime
import json
import os
import random
import sys
import uuid

# --- Helper Utilities ---

def random_date(start_days_ago=365, end_days_ago=0):
    start = datetime.datetime.now() - datetime.timedelta(days=start_days_ago)
    end = datetime.datetime.now() - datetime.timedelta(days=end_days_ago)
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return (start + datetime.timedelta(seconds=random_seconds)).strftime("%Y-%m-%d %H:%M:%S")

FIRST_NAMES = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Sam", "Jamie", "Avery", "Dakota", "Reese", "Quinn", "Skyler", "Cameron", "Rowan"]
LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson"]
CITIES = [
    ("New York", "NY", "USA"), ("San Francisco", "CA", "USA"), ("Austin", "TX", "USA"),
    ("Chicago", "IL", "USA"), ("Seattle", "WA", "USA"), ("London", "UK", "UK"),
    ("Toronto", "ON", "Canada"), ("Berlin", "BE", "Germany"), ("Tokyo", "TYO", "Japan"),
    ("Sydney", "NSW", "Australia")
]
CHANNELS = ["Direct", "Organic Search", "Paid Search", "Social Media", "Email Referral", "Affiliate"]
COMPANY_SUFFIXES = ["Inc", "Corp", "Labs", "Technologies", "Systems", "Health", "Solutions", "Global"]

# --- Dynamic Schema Engine ---

def generate_from_schema(schema_data, output_dir):
    """
    Generates CSV files for multiple relational tables specified in schema_data.
    Maintains foreign key referential integrity across generated tables.
    """
    os.makedirs(output_dir, exist_ok=True)
    generated_tables = {}  # table_name -> list of dict rows
    generated_pks = {}     # table_name -> list of primary key values

    tables = schema_data.get("tables", [])
    if not tables:
        raise ValueError("Schema must contain a 'tables' list.")

    print(f"\n[DYNAMIC GENERATOR] Processing {len(tables)} table specifications...")

    for table in tables:
        t_name = table.get("name")
        row_count = table.get("row_count", 100)
        columns = table.get("columns", [])
        
        csv_path = os.path.join(output_dir, f"{t_name}.csv")
        table_rows = []
        pk_col_name = None
        pk_values = []

        # Identify primary key column if any
        for col in columns:
            if col.get("type") in ["primary_key", "pk", "id"]:
                pk_col_name = col.get("name")

        fieldnames = [col.get("name") for col in columns]

        with open(csv_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()

            for i in range(1, row_count + 1):
                row = {}
                for col in columns:
                    c_name = col.get("name")
                    c_type = col.get("type", "string")

                    if c_type in ["primary_key", "pk", "id"]:
                        val = i
                        pk_values.append(val)
                    elif c_type == "foreign_key":
                        target_t = col.get("target_table")
                        if target_t in generated_pks and generated_pks[target_t]:
                            val = random.choice(generated_pks[target_t])
                        else:
                            val = random.randint(1, 50)
                    elif c_type == "first_name":
                        val = random.choice(FIRST_NAMES)
                    elif c_type == "last_name":
                        val = random.choice(LAST_NAMES)
                    elif c_type == "email":
                        fn = row.get("first_name", random.choice(FIRST_NAMES)).lower()
                        ln = row.get("last_name", random.choice(LAST_NAMES)).lower()
                        val = f"{fn}.{ln}{i}@example.com"
                    elif c_type == "company_name":
                        val = f"Company_{i:03d} {random.choice(COMPANY_SUFFIXES)}"
                    elif c_type == "city":
                        val = random.choice(CITIES)[0]
                    elif c_type == "state":
                        val = random.choice(CITIES)[1]
                    elif c_type == "country":
                        val = random.choice(CITIES)[2]
                    elif c_type == "choice":
                        options = col.get("options", ["Option A", "Option B", "Option C"])
                        weights = col.get("weights")
                        val = random.choices(options, weights=weights)[0] if weights else random.choice(options)
                    elif c_type == "integer":
                        c_min = col.get("min", 1)
                        c_max = col.get("max", 1000)
                        val = random.randint(c_min, c_max)
                    elif c_type == "float":
                        c_min = col.get("min", 10.0)
                        c_max = col.get("max", 500.0)
                        c_round = col.get("round", 2)
                        val = round(random.uniform(c_min, c_max), c_round)
                    elif c_type == "timestamp":
                        start_d = col.get("days_ago_start", 365)
                        end_d = col.get("days_ago_end", 0)
                        val = random_date(start_days_ago=start_d, end_days_ago=end_d)
                    elif c_type == "uuid":
                        val = str(uuid.uuid4())
                    else:
                        val = f"sample_{c_name}_{i}"

                    row[c_name] = val

                table_rows.append(row)
                writer.writerow(row)

        generated_tables[t_name] = table_rows
        if pk_col_name and pk_values:
            generated_pks[t_name] = pk_values
        elif pk_values:
            generated_pks[t_name] = pk_values

        print(f"  [SUCCESS] Generated '{t_name}.csv' ({row_count} rows)")

# --- Pre-packaged Vertical Generators ---

def generate_ecommerce(output_dir, num_users=100, num_products=30, num_orders=300):
    schema = {
        "tables": [
            {
                "name": "users",
                "row_count": num_users,
                "columns": [
                    {"name": "user_id", "type": "primary_key"},
                    {"name": "first_name", "type": "first_name"},
                    {"name": "last_name", "type": "last_name"},
                    {"name": "email", "type": "email"},
                    {"name": "age", "type": "integer", "min": 18, "max": 75},
                    {"name": "gender", "type": "choice", "options": ["M", "F", "Non-binary"]},
                    {"name": "city", "type": "city"},
                    {"name": "state", "type": "state"},
                    {"name": "country", "type": "country"},
                    {"name": "traffic_source", "type": "choice", "options": CHANNELS},
                    {"name": "created_at", "type": "timestamp", "days_ago_start": 730, "days_ago_end": 30}
                ]
            },
            {
                "name": "products",
                "row_count": num_products,
                "columns": [
                    {"name": "product_id", "type": "primary_key"},
                    {"name": "product_name", "type": "choice", "options": ["Smartphone Pro", "Wireless Earbuds", "Running Shoes", "Leather Jacket", "Coffee Espresso Maker", "4K Gaming Monitor"]},
                    {"name": "category", "type": "choice", "options": ["Electronics", "Apparel", "Home & Kitchen", "Beauty"]},
                    {"name": "brand", "type": "choice", "options": ["Brand-Alpha", "Brand-Apex", "Brand-Vortex", "Brand-Zenith"]},
                    {"name": "cost", "type": "float", "min": 15.0, "max": 150.0, "round": 2},
                    {"name": "retail_price", "type": "float", "min": 25.0, "max": 350.0, "round": 2}
                ]
            },
            {
                "name": "orders",
                "row_count": num_orders,
                "columns": [
                    {"name": "order_id", "type": "primary_key"},
                    {"name": "user_id", "type": "foreign_key", "target_table": "users"},
                    {"name": "status", "type": "choice", "options": ["Complete", "Processing", "Shipped", "Cancelled", "Returned"], "weights": [0.65, 0.15, 0.1, 0.05, 0.05]},
                    {"name": "created_at", "type": "timestamp", "days_ago_start": 180, "days_ago_end": 0},
                    {"name": "num_items_ordered", "type": "integer", "min": 1, "max": 5}
                ]
            },
            {
                "name": "order_items",
                "row_count": num_orders * 2,
                "columns": [
                    {"name": "order_item_id", "type": "primary_key"},
                    {"name": "order_id", "type": "foreign_key", "target_table": "orders"},
                    {"name": "product_id", "type": "foreign_key", "target_table": "products"},
                    {"name": "sale_price", "type": "float", "min": 20.0, "max": 300.0, "round": 2},
                    {"name": "created_at", "type": "timestamp", "days_ago_start": 180, "days_ago_end": 0}
                ]
            }
        ]
    }
    generate_from_schema(schema, output_dir)

def generate_saas(output_dir, num_accounts=80, num_subscriptions=150):
    schema = {
        "tables": [
            {
                "name": "accounts",
                "row_count": num_accounts,
                "columns": [
                    {"name": "account_id", "type": "primary_key"},
                    {"name": "company_name", "type": "company_name"},
                    {"name": "industry", "type": "choice", "options": ["Fintech", "Healthtech", "E-Commerce", "Cybersecurity", "SaaS/B2B"]},
                    {"name": "tier", "type": "choice", "options": ["Starter", "Professional", "Enterprise"]},
                    {"name": "region", "type": "choice", "options": ["AMER", "EMEA", "APAC"]},
                    {"name": "created_at", "type": "timestamp", "days_ago_start": 500, "days_ago_end": 30}
                ]
            },
            {
                "name": "subscriptions",
                "row_count": num_subscriptions,
                "columns": [
                    {"name": "subscription_id", "type": "primary_key"},
                    {"name": "account_id", "type": "foreign_key", "target_table": "accounts"},
                    {"name": "plan_tier", "type": "choice", "options": ["Starter", "Professional", "Enterprise"]},
                    {"name": "mrr_amount", "type": "choice", "options": [299.0, 999.0, 3499.0]},
                    {"name": "status", "type": "choice", "options": ["Active", "Active", "Active", "Cancelled"]},
                    {"name": "start_date", "type": "timestamp", "days_ago_start": 400, "days_ago_end": 60}
                ]
            }
        ]
    }
    generate_from_schema(schema, output_dir)

def main():
    parser = argparse.ArgumentParser(description="Synthetic Data Generator for Looker CE Demo Kit")
    parser.add_argument("--scenario", choices=["ecommerce", "saas"], help="Pre-packaged demo scenario vertical")
    parser.add_argument("--schema-file", help="Path to custom schema JSON file")
    parser.add_argument("--schema-json", help="Inline JSON string defining multi-table schema")
    parser.add_argument("--output-dir", default="/tmp/demo_data", help="Output directory for generated CSV files")
    parser.add_argument("--num-records", type=int, default=100, help="Base scale factor for primary entity records")
    args = parser.parse_args()

    if args.schema_file:
        with open(args.schema_file, "r", encoding="utf-8") as f:
            schema_data = json.load(f)
        generate_from_schema(schema_data, args.output_dir)
    elif args.schema_json:
        schema_data = json.loads(args.schema_json)
        generate_from_schema(schema_data, args.output_dir)
    elif args.scenario == "ecommerce":
        generate_ecommerce(args.output_dir, num_users=args.num_records, num_products=30, num_orders=args.num_records * 3)
    elif args.scenario == "saas":
        generate_saas(args.output_dir, num_accounts=args.num_records, num_subscriptions=int(args.num_records * 1.5))
    else:
        print("[ERROR] Must specify one of: --scenario, --schema-file, or --schema-json")
        sys.exit(1)

if __name__ == "__main__":
    main()
