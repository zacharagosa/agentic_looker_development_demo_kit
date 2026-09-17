view: optical_span_anomalies {
  sql_table_name: `demo_telecom_network_analytics.optical_span_anomalies` ;;

  dimension: pk {
    primary_key: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.timestamp AS STRING), '_', ${TABLE}.span_id) ;;
    hidden: yes
  }

  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: span_id {
    type: string
    sql: ${TABLE}.span_id ;;
    label: "Optical Span ID"
  }

  dimension: route_id {
    type: string
    sql: ${TABLE}.route_id ;;
    label: "Route ID"
  }

  dimension: attenuation_db_per_km {
    type: number
    sql: ${TABLE}.attenuation_db_per_km ;;
    value_format_name: decimal_3
    label: "Attenuation (dB/km)"
  }

  dimension: optical_return_loss_db {
    type: number
    sql: ${TABLE}.optical_return_loss_db ;;
    value_format_name: decimal_1
    label: "Optical Return Loss (dB)"
  }

  dimension: osnr_db {
    type: number
    sql: ${TABLE}.osnr_db ;;
    value_format_name: decimal_1
    label: "OSNR (dB)"
  }

  dimension: bit_error_rate_pre_fec {
    type: number
    sql: ${TABLE}.bit_error_rate_pre_fec ;;
    value_format: "0.00E+00"
    label: "Pre-FEC Bit Error Rate"
  }

  dimension: edfa_output_power_dbm {
    type: number
    sql: ${TABLE}.edfa_output_power_dbm ;;
    value_format_name: decimal_1
    label: "EDFA Output Power (dBm)"
  }

  dimension: span_temperature_celsius {
    type: number
    sql: ${TABLE}.span_temperature_celsius ;;
    value_format_name: decimal_1
    label: "Hut Temperature (°C)"
  }

  dimension: das_vibration_index {
    type: number
    sql: ${TABLE}.das_vibration_index ;;
    value_format_name: decimal_1
    label: "DAS Acoustic Vibration Index"
  }

  dimension: is_anomaly {
    type: yesno
    sql: ${TABLE}.is_anomaly ;;
    label: "Optical Anomaly Flag"
  }

  dimension: lower_bound {
    type: number
    sql: ${TABLE}.lower_bound ;;
    value_format_name: decimal_3
    label: "Expected Lower dB/km"
  }

  dimension: upper_bound {
    type: number
    sql: ${TABLE}.upper_bound ;;
    value_format_name: decimal_3
    label: "Expected Upper dB/km"
  }

  dimension: anomaly_probability {
    type: number
    sql: ${TABLE}.anomaly_probability ;;
    value_format_name: percent_1
    label: "Anomaly Confidence"
  }

  dimension: optical_health_status {
    type: string
    sql: ${TABLE}.optical_health_status ;;
    label: "Optical Health Verdict"
    description: "CRITICAL_DEGRADATION, ELEVATED_LOSS, or NOMINAL"
  }

  measure: count {
    type: count
  }

  measure: optical_anomaly_count {
    type: count
    filters: [is_anomaly: "yes"]
    label: "Total Optical Anomalies Detected"
  }

  measure: avg_attenuation_db_per_km {
    type: average
    sql: ${attenuation_db_per_km} ;;
    value_format_name: decimal_3
    label: "Avg Attenuation (dB/km)"
  }

  measure: avg_osnr_db {
    type: average
    sql: ${osnr_db} ;;
    value_format_name: decimal_1
    label: "Avg OSNR (dB)"
  }

  measure: max_attenuation_db_per_km {
    type: max
    sql: ${attenuation_db_per_km} ;;
    value_format_name: decimal_3
    label: "Max Attenuation Recorded (dB/km)"
  }
}
