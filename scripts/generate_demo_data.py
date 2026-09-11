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

FIBER_NODES_DATA = [
    ("Chicago Carrier Hotel (ORD-1)", "Carrier Hotel", "Chicago", "IL", 41.8781, -87.6298, 128),
    ("Denver Datacenter (DEN-2)", "Hyperscale Datacenter", "Denver", "CO", 39.7392, -104.9903, 64),
    ("Ashburn Data Center Alley (IAD-1)", "Hyperscale Datacenter", "Ashburn", "VA", 39.0438, -77.4874, 128),
    ("Dallas Infomart (DFW-1)", "Carrier Hotel", "Dallas", "TX", 32.7767, -96.7970, 96),
    ("Atlanta Telx Interconnect (ATL-1)", "Carrier Hotel", "Atlanta", "GA", 33.7490, -84.3880, 64),
    ("New York 60 Hudson (NYC-1)", "Carrier Hotel", "New York", "NY", 40.7128, -74.0060, 128),
    ("Seattle Westin Building (SEA-1)", "Carrier Hotel", "Seattle", "WA", 47.6062, -122.3321, 64),
    ("San Jose Equinix SV1 (SJC-1)", "Hyperscale Datacenter", "San Jose", "CA", 37.3382, -121.8863, 128),
    ("Phoenix CoreSite (PHX-1)", "Hyperscale Datacenter", "Phoenix", "AZ", 33.4484, -112.0740, 64),
    ("Minneapolis Metro PoP (MSP-1)", "Metro PoP", "Minneapolis", "MN", 44.9778, -93.2650, 32),
    ("Omaha ILA Regen Hut (OMA-1)", "ILA Regen Hut", "Omaha", "NE", 41.2565, -95.9345, 16),
    ("Kansas City PoP (MCI-1)", "Metro PoP", "Kansas City", "MO", 39.0997, -94.5786, 32),
    ("Salt Lake City ILA (SLC-1)", "ILA Regen Hut", "Salt Lake City", "UT", 40.7608, -111.8910, 16),
    ("Pittsburgh PoP (PIT-1)", "Metro PoP", "Pittsburgh", "PA", 40.4406, -79.9959, 32),
    ("Columbus Hyperscale (CMH-1)", "Hyperscale Datacenter", "Columbus", "OH", 39.9612, -82.9988, 64),
    ("St. Louis Gateway (STL-1)", "Metro PoP", "St. Louis", "MO", 38.6270, -90.1994, 32),
    ("Indianapolis ILA (IND-1)", "ILA Regen Hut", "Indianapolis", "IN", 39.7684, -86.1581, 16),
    ("Cleveland PoP (CLE-1)", "Metro PoP", "Cleveland", "OH", 41.4993, -81.6944, 32),
    ("Charlotte Interconnect (CLT-1)", "Carrier Hotel", "Charlotte", "NC", 35.2271, -80.8431, 48),
    ("Nashville Regen Station (BNA-1)", "ILA Regen Hut", "Nashville", "TN", 36.1627, -86.7816, 16),
]

def generate_fiber_telecom(output_dir, num_nodes=20, num_spans=35, num_circuits=120, num_telemetry=500, num_incidents=30):
    """
    Generates realistic 5-table normalized relational dataset for B2B enterprise fiber infrastructure.
    Includes network_nodes, fiber_spans, circuits, optical_telemetry_logs, and network_incidents_outages.
    """
    os.makedirs(output_dir, exist_ok=True)
    print(f"\n[FIBER INFRASTRUCTURE GENERATOR] Generating 5 normalized tables in {output_dir}...")

    # 1. network_nodes
    nodes = []
    nodes_csv = os.path.join(output_dir, "network_nodes.csv")
    node_fieldnames = ["node_id", "node_name", "facility_type", "city", "state", "latitude", "longitude", "chassis_capacity", "status"]
    with open(nodes_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=node_fieldnames)
        writer.writeheader()
        for i in range(1, num_nodes + 1):
            base_idx = (i - 1) % len(FIBER_NODES_DATA)
            n_name, f_type, city, state, lat, lng, capacity = FIBER_NODES_DATA[base_idx]
            if i > len(FIBER_NODES_DATA):
                n_name = f"{city} Secondary Node {i} ({state}-{i})"
                lat += round(random.uniform(-0.15, 0.15), 4)
                lng += round(random.uniform(-0.15, 0.15), 4)
            node_row = {
                "node_id": i,
                "node_name": n_name,
                "facility_type": f_type,
                "city": city,
                "state": state,
                "latitude": lat,
                "longitude": lng,
                "chassis_capacity": capacity,
                "status": "Active" if random.random() < 0.95 else "Maintenance"
            }
            nodes.append(node_row)
            writer.writerow(node_row)
    print(f"  [SUCCESS] Generated 'network_nodes.csv' ({len(nodes)} rows)")

    # 2. fiber_spans
    spans = []
    spans_csv = os.path.join(output_dir, "fiber_spans.csv")
    span_fieldnames = ["span_id", "span_name", "origin_node_id", "terminus_node_id", "fiber_type", "strand_count", "route_miles", "attenuation_db_per_km", "max_capacity_tbps"]
    fiber_types = ["Corning SMF-28 Ultra", "NZD-LEAF Optical Fiber", "G.652.D Standard Singlemode", "OFS TrueWave RS"]
    with open(spans_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=span_fieldnames)
        writer.writeheader()
        for i in range(1, num_spans + 1):
            origin = random.choice(nodes)
            terminus = random.choice([n for n in nodes if n["node_id"] != origin["node_id"]])
            # Approximate great-circle distance miles from coordinates
            dlat = origin["latitude"] - terminus["latitude"]
            dlng = origin["longitude"] - terminus["longitude"]
            approx_dist = round(max(35.0, ((dlat**2 + dlng**2)**0.5) * 69.0 * random.uniform(1.05, 1.35)), 1)
            span_row = {
                "span_id": i,
                "span_name": f"SPAN-{origin['city'][:3].upper()}-{terminus['city'][:3].upper()}-{i:03d}",
                "origin_node_id": origin["node_id"],
                "terminus_node_id": terminus["node_id"],
                "fiber_type": random.choice(fiber_types),
                "strand_count": random.choice([144, 288, 432, 864]),
                "route_miles": approx_dist,
                "attenuation_db_per_km": round(random.uniform(0.185, 0.245), 3),
                "max_capacity_tbps": random.choice([19.2, 25.6, 38.4, 51.2])
            }
            spans.append(span_row)
            writer.writerow(span_row)
    print(f"  [SUCCESS] Generated 'fiber_spans.csv' ({len(spans)} rows)")

    # 3. circuits
    circuits = []
    circuits_csv = os.path.join(output_dir, "circuits.csv")
    circuit_fieldnames = ["circuit_id", "span_id", "customer_segment", "circuit_type", "bandwidth_gbps", "monthly_recurring_revenue", "contracted_sla_pct", "status"]
    segments = ["Hyperscaler Cloud", "Tier-1 Investment Bank", "Global Streaming CDN", "Healthcare HealthTech", "Autonomous AI Cluster", "Tier-2 Carrier"]
    ckt_types = ["400G Wavelength", "Dark Fiber Pair", "100G Optical Wave", "Cloud Interconnect (Direct)", "10G Protected Ethernet"]
    with open(circuits_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=circuit_fieldnames)
        writer.writeheader()
        for i in range(1, num_circuits + 1):
            span = random.choice(spans)
            c_type = random.choice(ckt_types)
            bw = 400 if "400G" in c_type else (100 if "100G" in c_type else (10 if "10G" in c_type else 800))
            sla = random.choices([99.999, 99.99, 99.9], weights=[0.6, 0.3, 0.1])[0]
            base_mrr = 2800.0 if bw == 100 else (7500.0 if bw == 400 else 12500.0)
            if sla == 99.999:
                base_mrr *= 1.35
            ckt_row = {
                "circuit_id": f"CKT-{bw}G-{span['span_name'].split('-')[1]}-{span['span_name'].split('-')[2]}-{i:04d}",
                "span_id": span["span_id"],
                "customer_segment": random.choice(segments),
                "circuit_type": c_type,
                "bandwidth_gbps": bw,
                "monthly_recurring_revenue": round(base_mrr * random.uniform(0.9, 1.25), 2),
                "contracted_sla_pct": sla,
                "status": random.choices(["Active", "Degraded", "Down"], weights=[0.88, 0.09, 0.03])[0]
            }
            circuits.append(ckt_row)
            writer.writerow(ckt_row)
    print(f"  [SUCCESS] Generated 'circuits.csv' ({len(circuits)} rows)")

    # 4. optical_telemetry_logs
    telemetry_csv = os.path.join(output_dir, "optical_telemetry_logs.csv")
    telem_fieldnames = ["log_id", "span_id", "circuit_id", "rx_optical_power_dbm", "tx_optical_power_dbm", "chromatic_dispersion_ps_nm", "optical_snr_db", "temperature_c", "log_timestamp"]
    with open(telemetry_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=telem_fieldnames)
        writer.writeheader()
        for i in range(1, num_telemetry + 1):
            ckt = random.choice(circuits)
            # Normal healthy Rx power is between -12.0 and -18.0 dBm. Degraded is -22.0 to -28.0 dBm.
            if ckt["status"] == "Active":
                rx_power = round(random.uniform(-14.0, -19.5), 2)
                osnr = round(random.uniform(22.0, 32.0), 1)
            elif ckt["status"] == "Degraded":
                rx_power = round(random.uniform(-22.5, -28.0), 2)
                osnr = round(random.uniform(14.0, 18.5), 1)
            else:  # Down
                rx_power = round(random.uniform(-31.0, -38.5), 2)
                osnr = round(random.uniform(8.0, 12.0), 1)

            tx_power = round(random.uniform(-1.5, 3.5), 2)
            dispersion = round(random.uniform(150.0, 1600.0), 1)
            temp = round(random.uniform(22.0, 48.0), 1)
            ts = random_date(start_days_ago=45, end_days_ago=0)

            telem_row = {
                "log_id": i,
                "span_id": ckt["span_id"],
                "circuit_id": ckt["circuit_id"],
                "rx_optical_power_dbm": rx_power,
                "tx_optical_power_dbm": tx_power,
                "chromatic_dispersion_ps_nm": dispersion,
                "optical_snr_db": osnr,
                "temperature_c": temp,
                "log_timestamp": ts
            }
            writer.writerow(telem_row)
    print(f"  [SUCCESS] Generated 'optical_telemetry_logs.csv' ({num_telemetry} rows)")

    # 5. network_incidents_outages
    incidents_csv = os.path.join(output_dir, "network_incidents_outages.csv")
    inc_fieldnames = ["incident_id", "span_id", "circuit_id", "root_cause", "severity", "status", "repair_cost_usd", "estimated_sla_penalty_usd", "time_to_restore_hours", "reported_at", "resolved_at"]
    causes = ["Fiber Cut / Construction Backhoe", "Optical Attenuation / Microbend", "DWDM Transponder Laser Flap", "Acoustic Right-of-Way Vibration", "Substation Power Interruption"]
    with open(incidents_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=inc_fieldnames)
        writer.writeheader()
        for i in range(1, num_incidents + 1):
            ckt = random.choice(circuits)
            cause = random.choice(causes)
            sev = "P1 - Critical" if "Cut" in cause else ("P2 - High" if "Laser" in cause or "Attenuation" in cause else "P3 - Medium")
            status = random.choices(["Resolved", "Splicing In-Progress", "Investigating", "Active"], weights=[0.7, 0.15, 0.1, 0.05])[0]
            mttr = round(random.uniform(1.8, 12.5), 1)
            rep_date = random_date(start_days_ago=60, end_days_ago=1)
            
            # Resolve time
            if status == "Resolved":
                dt_rep = datetime.datetime.strptime(rep_date, "%Y-%m-%d %H:%M:%S")
                resolved_date = (dt_rep + datetime.timedelta(hours=mttr)).strftime("%Y-%m-%d %H:%M:%S")
            else:
                resolved_date = ""

            # SLA penalty exposure
            sla_mult = 1800.0 if sev == "P1 - Critical" else (650.0 if sev == "P2 - High" else 200.0)
            sla_penalty = round(mttr * sla_mult * random.uniform(0.8, 1.6), 2)
            repair_cost = round(random.uniform(4500.0, 48000.0), 2) if "Cut" in cause else round(random.uniform(800.0, 6500.0), 2)

            inc_row = {
                "incident_id": f"INC-2026-{i:04d}",
                "span_id": ckt["span_id"],
                "circuit_id": ckt["circuit_id"],
                "root_cause": cause,
                "severity": sev,
                "status": status,
                "repair_cost_usd": repair_cost,
                "estimated_sla_penalty_usd": sla_penalty,
                "time_to_restore_hours": mttr,
                "reported_at": rep_date,
                "resolved_at": resolved_date
            }
            writer.writerow(inc_row)
    print(f"  [SUCCESS] Generated 'network_incidents_outages.csv' ({num_incidents} rows)")

def main():
    parser = argparse.ArgumentParser(description="Synthetic Data Generator for Looker CE Demo Kit")
    parser.add_argument("--scenario", choices=["ecommerce", "saas", "fiber_telecom"], help="Pre-packaged demo scenario vertical")
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
    elif args.scenario == "fiber_telecom":
        generate_fiber_telecom(args.output_dir, num_nodes=20, num_spans=35, num_circuits=120, num_telemetry=500, num_incidents=30)
    else:
        print("[ERROR] Must specify one of: --scenario, --schema-file, or --schema-json")
        sys.exit(1)

if __name__ == "__main__":
    main()
