view: route_traffic_anomalies {
  sql_table_name: `aragosalooker.demo_zayo_network_analytics.route_traffic_anomalies` ;;

  # =========================================================================
  # DRILL SETS - Powers the "Corridor Anomaly Count -> Hourly ARIMA_PLUS
  # Telemetry Reading" drill demo path.
  # =========================================================================


  dimension: pk {
    primary_key: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.timestamp AS STRING), '_', ${TABLE}.route_id) ;;
    hidden: yes
  }

  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month, hour_of_day]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: route_id {
    type: string
    sql: ${TABLE}.route_id ;;
    label: "Route ID"
  }

  dimension: route_name {
    type: string
    sql: ${TABLE}.route_name ;;
    label: "Corridor Name"
    drill_fields: [timestamp_date, route_name, total_anomalies_detected, avg_bandwidth_utilization_gbps, max_peak_utilization_gbps, avg_utilization_pct]
  }

  dimension: provisioned_capacity_gbps {
    type: number
    sql: ${TABLE}.provisioned_capacity_gbps ;;
    value_format_name: decimal_0
    label: "Provisioned Capacity (Gbps)"
  }

  dimension: bandwidth_utilization_gbps {
    type: number
    sql: ${TABLE}.bandwidth_utilization_gbps ;;
    value_format_name: decimal_1
    label: "Bandwidth Utilization (Gbps)"
  }

  dimension: peak_bandwidth_utilization_gbps {
    type: number
    sql: ${TABLE}.peak_bandwidth_utilization_gbps ;;
    value_format_name: decimal_1
    label: "Peak Utilization (Gbps)"
  }

  dimension: utilization_pct {
    type: number
    sql: ${TABLE}.utilization_pct ;;
    value_format_name: percent_1
    label: "Utilization %"
  }

  dimension: is_anomaly {
    type: yesno
    sql: ${TABLE}.is_anomaly ;;
    label: "BQML Anomaly Detected"
  }

  dimension: lower_bound {
    type: number
    sql: ${TABLE}.lower_bound ;;
    value_format_name: decimal_1
    label: "ARIMA Expected Lower Bound"
  }

  dimension: upper_bound {
    type: number
    sql: ${TABLE}.upper_bound ;;
    value_format_name: decimal_1
    label: "ARIMA Expected Upper Bound"
  }

  dimension: anomaly_probability {
    type: number
    sql: ${TABLE}.anomaly_probability ;;
    value_format_name: percent_1
    label: "Anomaly Confidence Score"
  }

  dimension: anomaly_category {
    type: string
    sql: ${TABLE}.anomaly_category ;;
    label: "Anomaly Classification"
    description: "TRAFFIC_SURGE, TRAFFIC_DROP, or NORMAL"
    drill_fields: [timestamp_time, route_name, anomaly_category, bandwidth_utilization_gbps, peak_bandwidth_utilization_gbps, lower_bound, upper_bound, deviation_pct, anomaly_probability, utilization_pct]
    html:
      {% if value == 'TRAFFIC_SURGE' %}
        <span style="background:#fff7ed;color:#c2410c;border:1px solid #fed7aa;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">▲ {{ value }}</span>
      {% elsif value == 'TRAFFIC_DROP' %}
        <span style="background:#fff1f2;color:#be123c;border:1px solid #fecdd3;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">▼ {{ value }}</span>
      {% else %}
        <span style="background:#ecfdf5;color:#047857;border:1px solid #a7f3d0;padding:2px 8px;border-radius:6px;font-weight:600;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: deviation_pct {
    type: number
    sql: ${TABLE}.deviation_pct ;;
    value_format_name: percent_1
    label: "Deviation from ARIMA Baseline %"
  }

  measure: count {
    type: count
    drill_fields: [timestamp_time, route_name, anomaly_category, bandwidth_utilization_gbps, peak_bandwidth_utilization_gbps, lower_bound, upper_bound, deviation_pct, anomaly_probability, utilization_pct]
  }

  measure: total_anomalies_detected {
    type: count
    filters: [is_anomaly: "yes"]
    label: "Total BQML Traffic Anomalies"
    description: "Click to drill into each individual ARIMA_PLUS anomaly event with its expected confidence bounds and deviation."
    drill_fields: [timestamp_time, route_name, anomaly_category, bandwidth_utilization_gbps, peak_bandwidth_utilization_gbps, lower_bound, upper_bound, deviation_pct, anomaly_probability, utilization_pct]
  }

  measure: avg_bandwidth_utilization_gbps {
    type: average
    sql: ${bandwidth_utilization_gbps} ;;
    value_format_name: decimal_1
    label: "Avg Bandwidth (Gbps)"
    drill_fields: [timestamp_date, route_name, total_anomalies_detected, avg_bandwidth_utilization_gbps, max_peak_utilization_gbps, avg_utilization_pct]
  }

  measure: max_peak_utilization_gbps {
    type: max
    sql: ${peak_bandwidth_utilization_gbps} ;;
    value_format_name: decimal_1
    label: "Max Peak Bandwidth (Gbps)"
    drill_fields: [timestamp_time, route_name, anomaly_category, bandwidth_utilization_gbps, peak_bandwidth_utilization_gbps, lower_bound, upper_bound, deviation_pct, anomaly_probability, utilization_pct]
  }

  measure: avg_utilization_pct {
    type: average
    sql: ${utilization_pct} ;;
    value_format_name: percent_1
    label: "Avg Utilization %"
    drill_fields: [timestamp_date, route_name, total_anomalies_detected, avg_bandwidth_utilization_gbps, max_peak_utilization_gbps, avg_utilization_pct]
  }
}
