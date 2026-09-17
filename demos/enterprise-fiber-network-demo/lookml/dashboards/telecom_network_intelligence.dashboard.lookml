---
- dashboard: telecom_autonomous_network_intelligence__anomaly_detection
  title: 'OptiCore Networks: Autonomous Network Intelligence & Anomaly Detection'
  preferred_viewer: dashboards-next
  description: 'Executive Command Center: BigQuery ML ARIMA Anomaly Detection, Optical
    Telemetry & Predictive Maintenance'
  preferred_slug: 1bZmH5XXvkvgCCjbMUXZyh
  theme_name: ''
  layout_granularity: granular
  layout: newspaper
  tabs:
  - name: "🚨 Executive Operations & Incident Risk"
    label: "🚨 Executive Operations & Incident Risk"
  - name: "📊 Telemetry & Anomaly Trends"
    label: "📊 Telemetry & Anomaly Trends"
  - name: "🌐 Physical Topology & Flow"
    label: "🌐 Physical Topology & Flow"
  elements:
  - title: Total Monitored Fiber Miles
    name: Total Monitored Fiber Miles
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: telecom_noc_executive_scorecard
    fields: [fiber_routes.total_route_miles]
    limit: 500
    accent_theme: opticore_emerald
    value_format_type: miles
    custom_subtitle: 8 Core US Fiber Corridors • ITU G.652.D
    badge_label: FIBER BACKBONE
    listen:
      corridor_name: fiber_routes.route_name
    row: 0
    col: 0
    width: 14
    height: 5
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: Total Backbone Capacity (Tbps)
    name: Total Backbone Capacity (Tbps)
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: telecom_noc_executive_scorecard
    fields: [fiber_routes.total_provisioned_capacity_tbps]
    limit: 500
    accent_theme: opticore_blue
    value_format_type: tbps
    custom_subtitle: 400G / 800G Coherent DWDM Waves
    badge_label: DWDM C-BAND
    listen:
      corridor_name: fiber_routes.route_name
    row: 0
    col: 14
    width: 16
    height: 5
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: BQML Traffic Anomalies (60d)
    name: BQML Traffic Anomalies (60d)
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: telecom_noc_executive_scorecard
    fields: [route_traffic_anomalies.total_anomalies_detected, route_traffic_anomalies.timestamp_week]
    fill_fields: [route_traffic_anomalies.timestamp_week]
    sorts: [route_traffic_anomalies.timestamp_week desc]
    limit: 500
    accent_theme: opticore_blue
    value_format_type: auto
    custom_subtitle: ARIMA_PLUS 95% Confidence Bounds
    badge_label: ARIMA_PLUS
    listen:
      corridor_name: fiber_routes.route_name
      time_window: route_traffic_anomalies.timestamp_date
    row: 5
    col: 0
    width: 19
    height: 8
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: Optical Degradation Flags
    name: Optical Degradation Flags
    model: telecom_network_analytics
    explore: optical_telemetry_and_predictive_maintenance
    type: telecom_noc_executive_scorecard
    fields: [optical_span_anomalies.optical_anomaly_count, optical_span_anomalies.timestamp_week]
    fill_fields: [optical_span_anomalies.timestamp_week]
    sorts: [optical_span_anomalies.timestamp_week desc]
    limit: 500
    accent_theme: opticore_crimson
    value_format_type: auto
    custom_subtitle: OTDR & EDFA Amplifier Telemetry
    badge_label: OTDR ALERT
    listen:
      corridor_name: fiber_routes.route_name
      time_window: optical_span_anomalies.timestamp_date
    row: 5
    col: 19
    width: 24
    height: 8
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: SLA Exposure Under Intervention
    name: SLA Exposure Under Intervention
    model: telecom_network_analytics
    explore: predictive_maintenance_queue
    type: telecom_noc_executive_scorecard
    fields: [predictive_maintenance_spans.total_sla_risk_exposure]
    limit: 500
    accent_theme: opticore_crimson
    value_format_type: currency
    custom_subtitle: AutoML Proactive Dispatch Queue
    badge_label: SLA PROTECTED
    listen:
      corridor_name: fiber_routes.route_name
      risk_tier: predictive_maintenance_spans.risk_tier
    row: 0
    col: 30
    width: 13
    height: 5
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: Autonomous Predictive Maintenance Action Queue (ML Failure Risk)
    name: Autonomous Predictive Maintenance Action Queue (ML Failure Risk)
    model: telecom_network_analytics
    explore: predictive_maintenance_queue
    type: telecom_predictive_maintenance_deck
    fields: [predictive_maintenance_spans.span_name, predictive_maintenance_spans.risk_tier,
      predictive_maintenance_spans.predicted_failure_prob, predictive_maintenance_spans.failure_timeframe,
      predictive_maintenance_spans.primary_anomaly_trigger, predictive_maintenance_spans.anomaly_metric_value,
      predictive_maintenance_spans.recommended_action, predictive_maintenance_spans.dispatch_priority,
      predictive_maintenance_spans.sla_financial_risk_usd]
    sorts: [predictive_maintenance_spans.predicted_failure_prob desc]
    limit: 20
    default_filter: ALL
    show_otdr_trace: true
    listen:
      corridor_name: fiber_routes.route_name
      risk_tier: predictive_maintenance_spans.risk_tier
    row: 13
    col: 0
    width: 72
    height: 16
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: 'Historical Outages: SLA Penalties & Incident Volume'
    name: 'Historical Outages: SLA Penalties & Incident Volume'
    model: telecom_network_analytics
    explore: noc_incidents_and_sla
    type: telecom_optical_spectrum_waterfall
    fields: [noc_incidents.incident_type, noc_incidents.total_penalties_usd, noc_incidents.count]
    sorts: [noc_incidents.total_penalties_usd desc]
    limit: 10
    chart_mode: root_cause_lollipop
    chart_subtitle: Historical Enterprise SLA Exposure & Incident Volume by Root Cause
    listen:
      corridor_name: fiber_routes.route_name
    row: 0
    col: 43
    width: 29
    height: 13
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: 'Critical Telemetry Spotlight: CHI-DEN-01-SPAN-02 Attenuation Degradation'
    name: 'Critical Telemetry Spotlight: CHI-DEN-01-SPAN-02 Attenuation Degradation'
    model: telecom_network_analytics
    explore: optical_telemetry_and_predictive_maintenance
    type: telecom_optical_spectrum_waterfall
    fields: [optical_span_anomalies.timestamp_date, optical_span_anomalies.avg_attenuation_db_per_km]
    filters:
      optical_span_anomalies.span_id: CHI-DEN-01-SPAN-02
    sorts: [optical_span_anomalies.timestamp_date asc]
    limit: 100
    chart_mode: optical_threshold_envelope
    anomaly_threshold: 0.25
    chart_subtitle: CHI-DEN-01-SPAN-02 • Daily Optical Attenuation (dB/km) vs. ITU-T
      G.652.D Bounds
    listen:
      time_window: optical_span_anomalies.timestamp_date
    row: 29
    col: 0
    width: 72
    height: 16
    tab_name: "🚨 Executive Operations & Incident Risk"
  - title: Daily Average Bandwidth Utilization (Gbps) by Route
    name: Daily Average Bandwidth Utilization (Gbps) by Route
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: looker_line
    fields: [route_traffic_anomalies.timestamp_date, route_traffic_anomalies.route_name,
      route_traffic_anomalies.avg_bandwidth_utilization_gbps]
    pivots: [route_traffic_anomalies.route_name]
    sorts: [route_traffic_anomalies.timestamp_date asc]
    limit: 500
    colors: ["#0284c7", "#0f172a", "#10b981", "#e11d48", "#d97706", "#475569", "#1d4ed8",
      "#334155"]
    series_colors: {}
    show_value_labels: false
    point_style: none
    interpolation: monotone
    listen:
      corridor_name: route_traffic_anomalies.route_name
      time_window: route_traffic_anomalies.timestamp_date
    row: 0
    col: 0
    width: 72
    height: 18
    tab_name: "📊 Telemetry & Anomaly Trends"
  - title: BQML Anomaly Frequency by Corridor
    name: BQML Anomaly Frequency by Corridor
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: telecom_optical_spectrum_waterfall
    fields: [route_traffic_anomalies.route_name, route_traffic_anomalies.total_anomalies_detected]
    sorts: [route_traffic_anomalies.total_anomalies_detected desc]
    limit: 10
    chart_mode: root_cause_lollipop
    chart_subtitle: ARIMA_PLUS Bandwidth & Optical Anomaly Frequency by Fiber Corridor
    listen:
      corridor_name: route_traffic_anomalies.route_name
      time_window: route_traffic_anomalies.timestamp_date
    row: 18
    col: 0
    width: 30
    height: 20
    tab_name: "📊 Telemetry & Anomaly Trends"
  - title: Corridor Bandwidth & Trend Velocity Matrix
    name: Corridor Bandwidth & Trend Velocity Matrix
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: sparkline_matrix_table
    fields: [route_traffic_anomalies.route_name, route_traffic_anomalies.timestamp_week,
      route_traffic_anomalies.avg_bandwidth_utilization_gbps]
    pivots: [route_traffic_anomalies.timestamp_week]
    sorts: [route_traffic_anomalies.route_name asc]
    limit: 100
    colorTheme: enterprise_light
    tableMode: sparkline_matrix
    showSparklines: true
    showMicroBars: true
    showVarianceBadge: true
    listen:
      corridor_name: route_traffic_anomalies.route_name
    row: 18
    col: 30
    width: 42
    height: 20
    tab_name: "📊 Telemetry & Anomaly Trends"
  - title: Multi-Corridor Optical Attenuation (dB/km) Telemetry Over Time
    name: Multi-Corridor Optical Attenuation (dB/km) Telemetry Over Time
    model: telecom_network_analytics
    explore: optical_telemetry_and_predictive_maintenance
    type: telecom_optical_spectrum_waterfall
    fields: [optical_span_anomalies.timestamp_date, optical_span_anomalies.span_id,
      optical_span_anomalies.avg_attenuation_db_per_km]
    pivots: [optical_span_anomalies.span_id]
    filters:
      optical_span_anomalies.span_id: CHI-DEN-01-SPAN-02,DEN-SLC-07-SPAN-02,ASH-ATL-02-SPAN-03,NYC-CHI-05-SPAN-01,LAX-LAS-08-SPAN-01
    sorts: [optical_span_anomalies.timestamp_date asc]
    limit: 500
    chart_mode: optical_threshold_envelope
    anomaly_threshold: 0.25
    chart_subtitle: Multi-Corridor Optical Attenuation (dB/km) Over Time vs. Anomaly
      Threshold
    listen:
      time_window: optical_span_anomalies.timestamp_date
    row: 38
    col: 0
    width: 72
    height: 18
    tab_name: "📊 Telemetry & Anomaly Trends"
  - title: OptiCore Continental Optical Fiber Backbone & Flow Dynamics
    name: OptiCore Continental Optical Fiber Backbone & Flow Dynamics
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: network_topology_graph
    fields: [fiber_routes.origin_city, fiber_routes.dest_city, fiber_routes.total_provisioned_capacity_tbps,
      fiber_routes.total_route_miles]
    sorts: [fiber_routes.total_provisioned_capacity_tbps desc 0]
    limit: 5000
    colorTheme: enterprise_light
    showExecutiveHUD: true
    showSearch: true
    listen:
      corridor_name: fiber_routes.route_name
    row: 0
    col: 0
    width: 72
    height: 28
    tab_name: "🌐 Physical Topology & Flow"
  - title: Fiber Corridor Architecture & Hyperscaler Interconnects
    name: Fiber Corridor Architecture & Hyperscaler Interconnects
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    type: looker_grid
    fields: [fiber_routes.route_name, fiber_routes.corridor, fiber_routes.route_type,
      fiber_routes.optical_fiber_type, fiber_routes.distance_miles, fiber_routes.provisioned_capacity_tbps,
      fiber_routes.active_wavelengths, fiber_routes.key_hyperscalers, fiber_routes.status]
    sorts: [fiber_routes.provisioned_capacity_tbps desc]
    limit: 20
    header_background_color: "#f8fafc"
    header_font_color: "#0f172a"
    listen:
      corridor_name: fiber_routes.route_name
    row: 28
    col: 0
    width: 72
    height: 14
    tab_name: "🌐 Physical Topology & Flow"
  filters:
  - name: corridor_name
    title: Route Corridor
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: inline
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    listens_to_filters: []
    field: fiber_routes.route_name
  - name: time_window
    title: Time Window
    type: field_filter
    default_value: 60 day
    allow_multiple_values: false
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
    model: telecom_network_analytics
    explore: network_operations_and_anomalies
    listens_to_filters: []
    field: route_traffic_anomalies.timestamp_date
  - name: risk_tier
    title: Risk Tier
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: inline
    model: telecom_network_analytics
    explore: predictive_maintenance_queue
    listens_to_filters: []
    field: predictive_maintenance_spans.risk_tier
