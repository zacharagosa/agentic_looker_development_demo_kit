connection: "telecom_bigquery_conn"

include: "/views/*.view.lkml"
include: "/dashboards/**/*.dashboard.lookml"

explore: network_operations_and_anomalies {
  label: "1. Network Operations & Traffic Anomaly Intelligence"
  view_name: route_traffic_anomalies

  join: fiber_routes {
    type: left_outer
    sql_on: ${route_traffic_anomalies.route_id} = ${fiber_routes.route_id} ;;
    relationship: many_to_one
  }
}

explore: optical_telemetry_and_predictive_maintenance {
  label: "2. Optical Telemetry, BQML Degradation & Maintenance"
  view_name: optical_span_anomalies

  join: fiber_routes {
    type: left_outer
    sql_on: ${optical_span_anomalies.route_id} = ${fiber_routes.route_id} ;;
    relationship: many_to_one
  }

  join: predictive_maintenance_spans {
    type: left_outer
    sql_on: ${optical_span_anomalies.span_id} = ${predictive_maintenance_spans.span_id} ;;
    relationship: many_to_one
  }
}

explore: predictive_maintenance_queue {
  label: "3. Predictive Maintenance & Dispatch Priorities"
  view_name: predictive_maintenance_spans

  join: fiber_routes {
    type: left_outer
    sql_on: ${predictive_maintenance_spans.route_id} = ${fiber_routes.route_id} ;;
    relationship: many_to_one
  }
}

explore: noc_incidents_and_sla {
  label: "4. NOC Incidents, SLA Performance & Risk"
  view_name: noc_incidents

  join: fiber_routes {
    type: left_outer
    sql_on: ${noc_incidents.route_id} = ${fiber_routes.route_id} ;;
    relationship: many_to_one
  }
}
