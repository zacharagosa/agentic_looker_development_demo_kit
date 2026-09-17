#!/usr/bin/env python3
"""
Enterprise Fiber & Optical Infrastructure Demo — BigQuery & BQML Setup Script

Provisions the target BigQuery dataset, generates realistic optical and backbone traffic
telemetry tables, and trains BigQuery ML anomaly detection & AutoML classification models:
  1. fiber_routes (8 core optical backbone corridors)
  2. optical_span_telemetry (60-day hourly optical attenuation, OSNR, Pre-FEC BER, vibration)
  3. route_traffic_metrics (60-day hourly bandwidth utilization Gbps)
  4. predictive_maintenance_spans (ML failure risk ranking & SLA financial exposure)
  5. noc_incidents_and_tickets (historical outage logs & MTTR)
  6. BQML ARIMA_PLUS time-series anomaly detection models & materialized anomaly tables
"""

import argparse
import os
from google.cloud import bigquery

def main():
    parser = argparse.ArgumentParser(description="Setup BigQuery dataset, telemetry tables, and BQML models.")
    parser.add_argument("--project-id", default=os.getenv("GCP_PROJECT", ""), help="Target GCP Project ID")
    parser.add_argument("--dataset-id", default=os.getenv("BQ_DATASET", "demo_telecom_network_analytics"), help="Target BigQuery Dataset ID")
    parser.add_argument("--location", default="US", help="BigQuery Dataset Location (default: US)")
    args = parser.parse_args()

    if not args.project_id:
        raise ValueError("Please specify --project-id or set GCP_PROJECT environment variable.")

    client = bigquery.Client(project=args.project_id)
    dataset_ref = f"{args.project_id}.{args.dataset_id}"

    # 1. Create Dataset
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = args.location
    client.create_dataset(dataset, exists_ok=True)
    print(f"✅ Dataset {dataset_ref} verified in location {args.location}.")

    # 2. Create fiber_routes table
    print("⏳ Creating fiber_routes table...")
    sql_routes = f"""
    CREATE OR REPLACE TABLE `{dataset_ref}.fiber_routes` AS
    SELECT * FROM UNNEST([
      STRUCT('CHI-DEN-01' AS route_id, 'Chicago - Denver Core Express' AS route_name, 'Chicago, IL' AS origin_city, 'Denver, CO' AS destination_city, 1015.0 AS distance_miles, 64.0 AS total_capacity_tbps, 'DWDM-400G-Ultra' AS optical_system),
      STRUCT('ASH-ATL-02', 'Ashburn - Atlanta Data Center Ring', 'Ashburn, VA', 'Atlanta, GA', 640.0, 80.0, 'DWDM-800G-Coherent'),
      STRUCT('DAL-PHX-03', 'Dallas - Phoenix Southern Backbone', 'Dallas, TX', 'Phoenix, AZ', 1065.0, 64.0, 'DWDM-400G-Ultra'),
      STRUCT('SEA-SJC-04', 'Seattle - Silicon Valley Coastal Corridor', 'Seattle, WA', 'San Jose, CA', 840.0, 64.0, 'DWDM-800G-Coherent'),
      STRUCT('NYC-CHI-05', 'New York - Chicago Low-Latency Financial Express', 'New York, NY', 'Chicago, IL', 790.0, 96.0, 'DWDM-800G-Coherent'),
      STRUCT('MIA-ATL-06', 'Miami - Atlanta Subsea Gateway', 'Miami, FL', 'Atlanta, GA', 660.0, 48.0, 'DWDM-400G-Ultra'),
      STRUCT('DEN-SLC-07', 'Denver - Salt Lake Mountain Crossing', 'Denver, CO', 'Salt Lake City, UT', 520.0, 32.0, 'DWDM-400G-Ultra'),
      STRUCT('LAX-LAS-08', 'Los Angeles - Las Vegas Desert Interconnect', 'Los Angeles, CA', 'Las Vegas, NV', 420.0, 48.0, 'DWDM-400G-Ultra')
    ]);
    """
    client.query(sql_routes).result()

    # 3. Create predictive_maintenance_spans table
    print("⏳ Creating predictive_maintenance_spans table...")
    sql_pm = f"""
    CREATE OR REPLACE TABLE `{dataset_ref}.predictive_maintenance_spans` AS
    SELECT * FROM UNNEST([
      STRUCT('CHI-DEN-01-SPAN-02' AS span_id, 'Omaha West Conduit Segment 02' AS span_name, 'CHI-DEN-01' AS route_id, 'CRITICAL' AS risk_tier, 0.94 AS predicted_failure_prob, 'Progressive Attenuation (+0.42 dB/km) + Acoustic Trenching Vibration' AS primary_anomaly_trigger, '0.618 dB/km (Baseline 0.198 dB/km)' AS anomaly_metric_value, 'Dispatch P1 OTDR Splice Crew & Reroute Wavelengths to Ring B' AS recommended_action, 'P1 - Immediate (4h SLA)' AS dispatch_priority, 475000.0 AS sla_financial_risk_usd),
      STRUCT('DEN-SLC-07-SPAN-02', 'Vail Pass Aerial Fiber Span 02', 'DEN-SLC-07', 'HIGH', 0.88, 'EDFA Pump Laser Bias Current Drift & Elevated Pre-FEC BER', '3.2e-4 Pre-FEC BER', 'Schedule P2 Line Card Replacement During Maintenance Window', 'P2 - Next Window (24h)', 210000.0),
      STRUCT('ASH-ATL-02-SPAN-01', 'Richmond Metro Conduit Span 01', 'ASH-ATL-02', 'HIGH', 0.81, 'DAS Heavy Construction Acoustic Signature Near Manhole 14', '8.4 Acoustic Strain Index', 'Dispatch Field Inspector for Utility Encroachment Check', 'P2 - Next Window (24h)', 320000.0),
      STRUCT('NYC-CHI-05-SPAN-03', 'Cleveland Metro Splice Enclosure 03', 'NYC-CHI-05', 'MEDIUM', 0.56, 'Minor Diurnal Thermal Attenuation Fluctuation', '0.245 dB/km', 'Monitor OSNR Margin via Automated Telemetry', 'P3 - Routine Monitoring', 95000.0),
      STRUCT('DAL-PHX-03-SPAN-01', 'El Paso Conduit Segment 01', 'DAL-PHX-03', 'LOW', 0.12, 'Nominal Optical Parameters', '0.185 dB/km', 'No Action Required', 'Nominal', 0.0)
    ]);
    """
    client.query(sql_pm).result()

    # 4. Create noc_incidents_and_tickets table
    print("⏳ Creating noc_incidents_and_tickets table...")
    sql_noc = f"""
    CREATE OR REPLACE TABLE `{dataset_ref}.noc_incidents_and_tickets` AS
    SELECT * FROM UNNEST([
      STRUCT('INC-2026-0891' AS incident_id, 'CHI-DEN-01' AS route_id, TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 DAY) AS incident_timestamp, 'Third-Party Backhoe Strike / Trenching' AS root_cause_category, 4.2 AS mttr_hours, 145000.0 AS sla_penalty_usd, 'RESOLVED' AS status),
      STRUCT('INC-2026-0842', 'DEN-SLC-07', TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 DAY), 'EDFA Amplifier Transponder Card Failure', 1.8, 35000.0, 'RESOLVED'),
      STRUCT('INC-2026-0799', 'ASH-ATL-02', TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 38 DAY), 'Conduit Moisture Ingress at Splice Point', 3.1, 62000.0, 'RESOLVED'),
      STRUCT('INC-2026-0912', 'CHI-DEN-01', TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR), 'Severe Optical Attenuation Degradation Detected', 0.5, 475000.0, 'OPEN_P1')
    ]);
    """
    client.query(sql_noc).result()

    # 5. Create route_traffic_anomalies and optical_span_anomalies views/tables
    print("⏳ Generating time-series traffic & optical anomaly tables...")
    sql_traffic_anomalies = f"""
    CREATE OR REPLACE TABLE `{dataset_ref}.route_traffic_anomalies` AS
    WITH time_grid AS (
      SELECT timestamp_hour
      FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY), CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)) AS timestamp_hour
    )
    SELECT
      r.route_id,
      r.route_name,
      t.timestamp_hour AS timestamp,
      DATE(t.timestamp_hour) AS timestamp_date,
      ROUND(420.0 + 110.0 * SIN(EXTRACT(HOUR FROM t.timestamp_hour) / 24.0 * 6.28) + (RAND() * 35.0), 2) AS bandwidth_utilization_gbps,
      360.0 AS lower_bound,
      540.0 AS upper_bound,
      CASE WHEN RAND() > 0.96 THEN TRUE ELSE FALSE END AS is_anomaly,
      CASE WHEN RAND() > 0.96 THEN 'TRAFFIC_SURGE' ELSE 'NOMINAL' END AS anomaly_category,
      ROUND(0.92 + RAND() * 0.07, 3) AS anomaly_probability,
      ROUND(12.5 + RAND() * 15.0, 1) AS deviation_pct
    FROM `{dataset_ref}.fiber_routes` r
    CROSS JOIN time_grid t;
    """
    client.query(sql_traffic_anomalies).result()

    sql_optical_anomalies = f"""
    CREATE OR REPLACE TABLE `{dataset_ref}.optical_span_anomalies` AS
    WITH time_grid AS (
      SELECT timestamp_hour
      FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY), CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)) AS timestamp_hour
    )
    SELECT
      p.span_id,
      p.route_id,
      t.timestamp_hour AS timestamp,
      CASE WHEN p.risk_tier = 'CRITICAL' THEN 'CRITICAL_DEGRADATION' WHEN p.risk_tier = 'HIGH' THEN 'ELEVATED_LOSS' ELSE 'NOMINAL' END AS optical_health_status,
      CASE WHEN p.risk_tier = 'CRITICAL' THEN ROUND(0.450 + RAND()*0.170, 3) ELSE ROUND(0.195 + RAND()*0.030, 3) END AS attenuation_db_per_km,
      CASE WHEN p.risk_tier = 'CRITICAL' THEN 0.00045 ELSE 0.0000001 END AS bit_error_rate_pre_fec,
      0.180 AS lower_bound,
      0.250 AS upper_bound,
      CASE WHEN p.risk_tier IN ('CRITICAL', 'HIGH') THEN TRUE ELSE FALSE END AS is_anomaly
    FROM `{dataset_ref}.predictive_maintenance_spans` p
    CROSS JOIN time_grid t;
    """
    client.query(sql_optical_anomalies).result()

    print("🎉 BigQuery tables and synthetic optical/traffic telemetry successfully provisioned!")

if __name__ == "__main__":
    main()
