view: fiber_routes {
  sql_table_name: `demo_telecom_network_analytics.fiber_routes` ;;

  dimension: route_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.route_id ;;
    label: "Route ID"
    description: "Unique identifier for the fiber corridor"
  }

  dimension: route_name {
    type: string
    sql: ${TABLE}.route_name ;;
    label: "Route Corridor Name"
  }

  dimension: corridor {
    type: string
    sql: ${TABLE}.corridor ;;
    label: "Geographic Corridor"
  }

  dimension: route_type {
    type: string
    sql: ${TABLE}.route_type ;;
    label: "Route Architecture Type"
  }

  dimension: origin_city {
    type: string
    sql: ${TABLE}.origin_city ;;
    label: "Origin Metro"
  }

  dimension: dest_city {
    type: string
    sql: ${TABLE}.dest_city ;;
    label: "Destination Metro"
  }

  dimension: distance_miles {
    type: number
    sql: ${TABLE}.distance_miles ;;
    value_format_name: decimal_0
    label: "Distance (Miles)"
  }

  dimension: fiber_strands_count {
    type: number
    sql: ${TABLE}.fiber_strands_count ;;
    value_format_name: decimal_0
    label: "Fiber Strands Count"
  }

  dimension: active_wavelengths {
    type: number
    sql: ${TABLE}.active_wavelengths ;;
    value_format_name: decimal_0
    label: "Active Wavelengths"
  }

  dimension: provisioned_capacity_tbps {
    type: number
    sql: ${TABLE}.provisioned_capacity_tbps ;;
    value_format_name: decimal_1
    label: "Provisioned Capacity (Tbps)"
  }

  dimension: optical_fiber_type {
    type: string
    sql: ${TABLE}.optical_fiber_type ;;
    label: "Optical Fiber Spec"
  }

  dimension: key_hyperscalers {
    type: string
    sql: ${TABLE}.key_hyperscalers ;;
    label: "Connected Hyperscalers"
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    label: "Route Status"
  }

  measure: count {
    type: count
    drill_fields: [route_id, route_name, route_type, provisioned_capacity_tbps, distance_miles]
  }

  measure: total_route_miles {
    type: sum
    sql: ${distance_miles} ;;
    value_format_name: decimal_0
    label: "Total Fiber Route Miles"
  }

  measure: total_provisioned_capacity_tbps {
    type: sum
    sql: ${provisioned_capacity_tbps} ;;
    value_format_name: decimal_1
    label: "Total Capacity (Tbps)"
  }

  measure: total_active_wavelengths {
    type: sum
    sql: ${active_wavelengths} ;;
    value_format_name: decimal_0
    label: "Active Wavelengths Count"
  }
}
