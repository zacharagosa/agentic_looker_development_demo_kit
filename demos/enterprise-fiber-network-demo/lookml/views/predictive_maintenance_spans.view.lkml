view: predictive_maintenance_spans {
  sql_table_name: `demo_telecom_network_analytics.predictive_maintenance_spans` ;;

  # =========================================================================
  # DRILL SET - Powers the "SLA Exposure KPI -> At-Risk Span Detail" drill
  # demo path on Page 1 of the Autonomous Network Intelligence dashboard.
  # =========================================================================

  dimension: span_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.span_id ;;
    label: "Span ID"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  dimension: span_name {
    type: string
    sql: ${TABLE}.span_name ;;
    label: "Span Name & Section"
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
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  dimension: predicted_failure_prob {
    type: number
    sql: ${TABLE}.predicted_failure_prob ;;
    value_format_name: percent_1
    label: "ML Predicted Failure Probability"
  }

  dimension: risk_tier {
    type: string
    sql: ${TABLE}.risk_tier ;;
    label: "Risk Tier"
    description: "CRITICAL, HIGH, ELEVATED, MODERATE, LOW"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
    html:
      {% if value == 'CRITICAL' %}
        <span style="background:#fff1f2;color:#be123c;border:1px solid #fecdd3;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% elsif value == 'HIGH' %}
        <span style="background:#fff7ed;color:#c2410c;border:1px solid #fed7aa;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% elsif value == 'ELEVATED' %}
        <span style="background:#fffbeb;color:#b45309;border:1px solid #fde68a;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% elsif value == 'MODERATE' %}
        <span style="background:#f1f5f9;color:#1e293b;border:1px solid #cbd5e1;padding:2px 8px;border-radius:6px;font-weight:600;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% else %}
        <span style="background:#ecfdf5;color:#047857;border:1px solid #a7f3d0;padding:2px 8px;border-radius:6px;font-weight:600;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: failure_timeframe {
    type: string
    sql: ${TABLE}.failure_timeframe ;;
    label: "Estimated Failure Window"
  }

  dimension: primary_anomaly_trigger {
    type: string
    sql: ${TABLE}.primary_anomaly_trigger ;;
    label: "Primary Anomaly Root Trigger"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  dimension: anomaly_metric_value {
    type: string
    sql: ${TABLE}.anomaly_metric_value ;;
    label: "Telemetry Anomaly Reading"
  }

  dimension: recommended_action {
    type: string
    sql: ${TABLE}.recommended_action ;;
    label: "AI Recommended Engineering Action"
  }

  dimension: dispatch_priority {
    type: string
    sql: ${TABLE}.dispatch_priority ;;
    label: "Dispatch Priority Code"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  dimension: sla_financial_risk_usd {
    type: number
    sql: ${TABLE}.sla_financial_risk_usd ;;
    value_format_name: usd_0
    label: "SLA Financial Penalty at Risk"
  }

  dimension: assigned_quick_response_unit {
    type: string
    sql: ${TABLE}.assigned_quick_response_unit ;;
    label: "Assigned NOC Field Unit"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  dimension: action_status {
    type: string
    sql: ${TABLE}.action_status ;;
    label: "Field Action Status"
  }

  measure: count {
    type: count
    label: "Monitored Span Count"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  measure: total_sla_risk_exposure {
    type: sum
    sql: ${sla_financial_risk_usd} ;;
    value_format_name: usd_0
    label: "Total SLA Financial Exposure"
    description: "Click to drill into every at-risk fiber span contributing to this SLA exposure, with its AutoML failure probability and recommended dispatch action."
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  measure: critical_risk_span_count {
    type: count
    filters: [risk_tier: "CRITICAL,HIGH"]
    label: "Critical / High Risk Spans Count"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }

  measure: avg_failure_probability {
    type: average
    sql: ${predicted_failure_prob} ;;
    value_format_name: percent_1
    label: "Avg Failure Probability"
    drill_fields: [span_id, span_name, route_name, risk_tier, predicted_failure_prob, failure_timeframe, primary_anomaly_trigger, anomaly_metric_value, recommended_action, dispatch_priority, assigned_quick_response_unit, action_status, sla_financial_risk_usd]
  }
}
