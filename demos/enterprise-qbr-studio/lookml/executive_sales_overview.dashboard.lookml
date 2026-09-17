- dashboard: executive_sales_overview
  title: "Global Sales & Pipeline Executive Overview"
  description: "Executive command center showing all 57 quota-carrying sales reps, quota attainment distribution, and current pipeline breakdown across Closed Won, Commit, Upside, Pipeline, and Closed Lost."
  layout: newspaper
  preferred_viewer: dashboards-next
  style: modern
  crossfilter_enabled: true
  filters:

  - name: Quarter
    title: Quarter
    type: field_filter
    default_value: 2026-Q3
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_performance
    listens_to_filters: []
    field: qbr_rep_quota.fiscal_quarter_label

  - name: Manager
    title: Manager
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_performance
    listens_to_filters: []
    field: qbr_rep_roster.manager_name

  - name: Segment
    title: Segment
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: button_group, display: inline}
    model: saas_qbr
    explore: qbr_performance
    listens_to_filters: []
    field: qbr_rep_roster.segment

  - name: Region
    title: Region
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: button_group, display: inline}
    model: saas_qbr
    explore: qbr_performance
    listens_to_filters: []
    field: qbr_rep_roster.region

  elements:

  - title: Quota-Carrying Reps
    name: eo_kpi_reps
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.quota_carrying_reps]
    limit: 500
    custom_color_enabled: true
    custom_color: "#141A24"
    show_single_value_title: true
    single_value_title: "Active Reps"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 0
    width: 4
    height: 3

  - title: Reps Hitting Quota (≥100%)
    name: eo_kpi_hitting
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.reps_at_or_above_quota]
    limit: 500
    custom_color_enabled: true
    custom_color: "#10B981"
    show_single_value_title: true
    single_value_title: "Reps at Quota"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 4
    width: 4
    height: 3

  - title: "% Reps Hitting Quota"
    name: eo_kpi_pct_hitting
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.percent_reps_at_quota]
    limit: 500
    custom_color_enabled: true
    custom_color: "#4F46E5"
    show_single_value_title: true
    single_value_title: "% at Quota"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 8
    width: 4
    height: 3

  - title: Global Closed Won ARR
    name: eo_kpi_won
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_performance.total_won_arr]
    limit: 500
    custom_color_enabled: true
    custom_color: "#10B981"
    show_single_value_title: true
    single_value_title: "Closed Won ARR"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 12
    width: 4
    height: 3

  - title: Global ARR Quota
    name: eo_kpi_quota
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.total_arr_quota]
    limit: 500
    custom_color_enabled: true
    custom_color: "#141A24"
    show_single_value_title: true
    single_value_title: "Global Quota"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 16
    width: 4
    height: 3

  - title: Global Attainment %
    name: eo_kpi_attainment
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.arr_attainment]
    limit: 500
    custom_color_enabled: true
    custom_color: "#4F46E5"
    show_single_value_title: true
    single_value_title: "Attainment %"
    show_comparison: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 0
    col: 20
    width: 4
    height: 3

  - title: "Current Pipeline & Revenue by Forecast Category (Closed Won, Commit, Upside, Pipeline, Lost)"
    name: eo_pipeline_categories
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_roster.region, qbr_rep_performance.total_won_arr, qbr_rep_performance.total_commit_arr,
      qbr_rep_performance.total_upside_arr, qbr_rep_performance.total_early_pipeline_arr,
      qbr_rep_performance.total_lost_arr]
    sorts: [qbr_rep_performance.total_won_arr desc]
    limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: false
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ""
    stacking: ""
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    color_application:
      collection_id: looker_2026
      palette_id: looker_2026-categorical-0
    series_colors:
      qbr_rep_performance.total_won_arr: "#10B981"
      qbr_rep_performance.total_commit_arr: "#4F46E5"
      qbr_rep_performance.total_upside_arr: "#FFB000"
      qbr_rep_performance.total_early_pipeline_arr: "#00C0E8"
      qbr_rep_performance.total_lost_arr: "#64748B"
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 3
    col: 0
    width: 12
    height: 8

  - title: "Open Pipeline Breakdown by Forecast Category (ARR vs Deal Volume)"
    name: eo_open_forecast_breakdown
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_column
    fields: [qbr_deal_quality.forecast_category, qbr_deal_quality.total_arr, qbr_deal_quality.deal_count]
    filters:
      qbr_deal_quality.is_closed: "No"
    sorts: [qbr_deal_quality.total_arr desc]
    limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: false
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ""
    stacking: ""
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: false
    y_axes:
    - label: ""
      orientation: left
      series:
      - axisId: qbr_deal_quality.total_arr
        id: qbr_deal_quality.total_arr
        name: Pipeline ARR
      showLabels: false
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: ""
      orientation: right
      series:
      - axisId: qbr_deal_quality.deal_count
        id: qbr_deal_quality.deal_count
        name: Deals
      showLabels: false
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_types:
      qbr_deal_quality.deal_count: line
    series_colors:
      qbr_deal_quality.total_arr: "#4F46E5"
      qbr_deal_quality.deal_count: "#141A24"
    defaults_version: 1
    listen: {Manager: qbr_rep_roster.manager_name}
    row: 3
    col: 12
    width: 12
    height: 8

  - title: "Team Attainment & Quota Pacing by Sales Manager"
    name: eo_manager_pacing
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_roster.manager_name, qbr_rep_performance.total_won_arr, qbr_rep_quota.total_arr_quota,
      qbr_rep_quota.arr_attainment]
    sorts: [qbr_rep_quota.arr_attainment desc]
    limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: false
    show_y_axis_ticks: true
    show_x_axis_label: false
    show_x_axis_ticks: true
    legend_position: center
    show_value_labels: true
    y_axes:
    - label: ""
      orientation: left
      series:
      - axisId: qbr_rep_performance.total_won_arr
        id: qbr_rep_performance.total_won_arr
        name: Closed Won ARR
      - axisId: qbr_rep_quota.total_arr_quota
        id: qbr_rep_quota.total_arr_quota
        name: ARR Quota
      showLabels: false
      showValues: true
      type: linear
    - label: ""
      orientation: right
      series:
      - axisId: qbr_rep_quota.arr_attainment
        id: qbr_rep_quota.arr_attainment
        name: ARR Attainment %
      showLabels: false
      showValues: true
      type: linear
    series_types:
      qbr_rep_quota.arr_attainment: line
    series_colors:
      qbr_rep_performance.total_won_arr: "#10B981"
      qbr_rep_quota.total_arr_quota: "#141A24"
      qbr_rep_quota.arr_attainment: "#4F46E5"
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 11
    col: 0
    width: 14
    height: 8

  - title: "Sales Reps Hitting Quota vs. Behind Pace by Segment"
    name: eo_rep_quota_dist
    model: saas_qbr
    explore: qbr_performance
    type: looker_bar
    fields: [qbr_rep_roster.segment, qbr_rep_quota.reps_at_or_above_quota, qbr_rep_quota.reps_below_quota]
    sorts: [qbr_rep_roster.segment]
    limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: false
    show_y_axis_ticks: true
    show_x_axis_label: false
    show_x_axis_ticks: true
    stacking: normal
    legend_position: center
    show_value_labels: true
    series_colors:
      qbr_rep_quota.reps_at_or_above_quota: "#10B981"
      qbr_rep_quota.reps_below_quota: "#E11D48"
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 11
    col: 14
    width: 10
    height: 8

  - title: "All Sales Representatives — Quota Attainment & Pipeline Scorecard"
    name: eo_rep_leaderboard
    model: saas_qbr
    explore: qbr_performance
    type: looker_grid
    fields: [qbr_rep_roster.rep_name, qbr_rep_roster.manager_name, qbr_rep_roster.segment,
      qbr_rep_roster.region, qbr_rep_quota.total_arr_quota, qbr_rep_performance.total_won_arr,
      qbr_rep_quota.arr_attainment, qbr_rep_performance.total_commit_arr, qbr_rep_performance.total_upside_arr,
      qbr_rep_performance.total_lost_arr, qbr_rep_quota.pipeline_coverage_ratio]
    sorts: [qbr_rep_quota.arr_attainment desc]
    limit: 100
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: true
    header_text_alignment: left
    header_font_size: "12"
    rows_font_size: "12"
    conditional_formatting:
    - type: greater than
      value: 0.999
      background_color: "#D1FAE5"
      font_color: "#065F46"
      bold: true
      fields: [qbr_rep_quota.arr_attainment]
    - type: less than
      value: 0.7
      background_color: "#FEE2E2"
      font_color: "#991B1B"
      bold: true
      fields: [qbr_rep_quota.arr_attainment]
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment, Region: qbr_rep_roster.region}
    row: 19
    col: 0
    width: 24
    height: 11
