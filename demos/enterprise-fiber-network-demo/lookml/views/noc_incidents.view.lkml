view: noc_incidents {
  sql_table_name: `demo_telecom_network_analytics.noc_incidents_and_tickets` ;;

  # =========================================================================
  # DRILL SETS - Powers the guided "Executive KPI -> Root Cause -> Ticket"
  # drill demo path on Page 1 of the Autonomous Network Intelligence dashboard.
  # =========================================================================


  dimension: ticket_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ticket_id ;;
    label: "NOC Incident Ticket ID"
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  dimension: route_id {
    type: string
    sql: ${TABLE}.route_id ;;
    label: "Route ID"
  }

  dimension: span_id {
    type: string
    sql: ${TABLE}.span_id ;;
    label: "Span ID"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.created_timestamp ;;
  }

  dimension_group: resolved {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.resolved_timestamp ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    label: "Incident Status"
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}.incident_type ;;
    label: "Incident Classification"
    drill_fields: [root_cause_category, severity, count, sla_breach_count, total_penalties_usd]
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.severity ;;
    label: "Severity Level"
    html:
      {% if value == 'P1' or value == 'CRITICAL' %}
        <span style="background:#fff1f2;color:#be123c;border:1px solid #fecdd3;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% elsif value == 'P2' or value == 'HIGH' %}
        <span style="background:#fff7ed;color:#c2410c;border:1px solid #fed7aa;padding:2px 8px;border-radius:6px;font-weight:700;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% else %}
        <span style="background:#f1f5f9;color:#334155;border:1px solid #cbd5e1;padding:2px 8px;border-radius:6px;font-weight:600;font-family:monospace;font-size:11px;">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: root_cause_category {
    type: string
    sql: ${TABLE}.root_cause_category ;;
    label: "Root Cause"
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  dimension: impacted_wavelengths {
    type: number
    sql: ${TABLE}.impacted_wavelengths ;;
    value_format_name: decimal_0
    label: "Impacted Wavelength Channels"
  }

  dimension: impacted_enterprise_customers {
    type: string
    sql: ${TABLE}.impacted_enterprise_customers ;;
    label: "Impacted Hyperscaler / Enterprise Accounts"
  }

  dimension: sla_breach_occurred {
    type: yesno
    sql: ${TABLE}.sla_breach_occurred ;;
    label: "SLA Breach Occurred"
  }

  dimension: sla_breach_predicted {
    type: yesno
    sql: ${TABLE}.sla_breach_predicted ;;
    label: "SLA Breach Pre-Emptively Predicted"
    description: "Did the BQML / AutoML models flag this failure before the outage occurred?"
  }

  dimension: mttr_target_hours {
    type: number
    sql: ${TABLE}.mttr_target_hours ;;
    value_format_name: decimal_1
    label: "MTTR Target (Hours)"
  }

  dimension: financial_penalty_usd {
    type: number
    sql: ${TABLE}.financial_penalty_usd ;;
    value_format_name: usd_0
    label: "Financial Penalty Paid (USD)"
  }

  dimension: incident_summary {
    type: string
    sql: ${TABLE}.incident_summary ;;
    label: "NOC Technical Incident Log"
  }

  measure: count {
    type: count
    label: "Incident Count"
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  measure: total_penalties_usd {
    type: sum
    sql: ${financial_penalty_usd} ;;
    value_format_name: usd_0
    label: "Total SLA Penalties Incurred"
    description: "Click to drill into every individual NOC ticket that contributed to this SLA penalty exposure."
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  measure: sla_breach_count {
    type: count
    filters: [sla_breach_occurred: "yes"]
    label: "SLA Breach Incident Count"
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  measure: predicted_breach_count {
    type: count
    filters: [sla_breach_predicted: "yes"]
    label: "AI Pre-Emptively Predicted Breaches"
    description: "Incidents where BQML / AutoML flagged the failure before it occurred."
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }

  measure: avg_mttr_target_hours {
    type: average
    sql: ${mttr_target_hours} ;;
    value_format_name: decimal_1
    label: "Avg MTTR Target (Hours)"
    drill_fields: [ticket_id, created_date, severity, incident_type, root_cause_category, route_id, span_id, impacted_wavelengths, impacted_enterprise_customers, sla_breach_predicted, sla_breach_occurred, mttr_target_hours, financial_penalty_usd, incident_summary]
  }
}
