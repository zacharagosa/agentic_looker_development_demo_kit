- dashboard: my_qbr_scorecard
  title: "Executive QBR Scorecard & Attainment"
  description: "Everything a rep needs for their quarterly business review: quota, attainment, bookings mix, pipeline coverage and deal quality."
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

  - name: Sales Rep
    title: Sales Rep
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_performance
    listens_to_filters: [Manager, Segment]
    field: qbr_rep_roster.rep_name

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

  elements:

  # ------------------------------------------------------------------ KPI row
  - title: ARR Quota
    name: kpi_quota
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.total_arr_quota]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "ARR Quota"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 0
    col: 0
    width: 5
    height: 3

  - title: Closed Won ARR
    name: kpi_won
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_performance.total_won_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Closed Won ARR"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 0
    col: 5
    width: 5
    height: 3

  - title: Attainment
    name: kpi_attainment
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.arr_attainment]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Attainment %"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 0
    col: 10
    width: 5
    height: 3

  - title: Quota Gap
    name: kpi_gap
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.quota_gap]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Quota Gap"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 0
    col: 15
    width: 5
    height: 3

  - title: Pipeline Coverage
    name: kpi_coverage
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_quota.pipeline_coverage_ratio]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Pipeline Cov."
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 0
    col: 20
    width: 4
    height: 3

  # ------------------------------------------------------- quota vs bookings
  - title: Quota vs Bookings by Quarter
    name: quota_vs_bookings
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_quota.fiscal_quarter_label, qbr_rep_quota.total_arr_quota, qbr_rep_performance.total_won_arr,
      qbr_rep_quota.arr_attainment]
    sorts: [qbr_rep_quota.fiscal_quarter_label]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle_outline
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: false
    show_null_points: false
    interpolation: monotone
    series_types:
      qbr_rep_quota.arr_attainment: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_rep_quota.total_arr_quota,
            id: qbr_rep_quota.total_arr_quota, name: ARR Quota}, {axisId: qbr_rep_performance.total_won_arr,
            id: qbr_rep_performance.total_won_arr, name: Closed Won ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_rep_quota.arr_attainment,
            id: qbr_rep_quota.arr_attainment, name: Attainment}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment}
    row: 3
    col: 0
    width: 12
    height: 8

  # ------------------------------------------------- win rate & deal size
  - title: Win Rate & Average Deal Size
    name: winrate_dealsize
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_quota.fiscal_quarter_label, qbr_rep_performance.average_won_deal_arr,
      qbr_rep_performance.win_rate]
    sorts: [qbr_rep_quota.fiscal_quarter_label]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle_outline
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: false
    show_null_points: false
    interpolation: monotone
    series_types:
      qbr_rep_performance.win_rate: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_rep_performance.average_won_deal_arr,
            id: qbr_rep_performance.average_won_deal_arr, name: Avg Won Deal ARR}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}, {label: '', orientation: right, series: [
          {axisId: qbr_rep_performance.win_rate, id: qbr_rep_performance.win_rate,
            name: Win Rate}], showLabels: false, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment}
    row: 3
    col: 12
    width: 12
    height: 8

  # ---------------------------------------------------------- bookings mix
  - title: Bookings Mix — New Logo vs Expansion
    name: bookings_mix
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_quota.fiscal_quarter_label, qbr_rep_performance.total_new_logo_arr,
      qbr_rep_performance.total_expansion_arr]
    sorts: [qbr_rep_quota.fiscal_quarter_label]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_rep_performance.total_new_logo_arr,
            id: qbr_rep_performance.total_new_logo_arr, name: New Logo ARR}, {axisId: qbr_rep_performance.total_expansion_arr,
            id: qbr_rep_performance.total_expansion_arr, name: Expansion ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Segment: qbr_rep_roster.segment}
    row: 11
    col: 0
    width: 8
    height: 8

  # ------------------------------------------------- pipeline by category
  - title: Open Pipeline by Forecast Category
    name: pipeline_by_category
    model: saas_qbr
    explore: qbr_performance
    type: looker_bar
    fields: [qbr_rep_performance.total_commit_arr, qbr_rep_performance.total_upside_arr,
      qbr_rep_performance.total_early_pipeline_arr, qbr_rep_performance.total_omitted_arr]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 11
    col: 8
    width: 8
    height: 8

  # ---------------------------------------------------- deal quality risk
  - title: Pipeline Quality Exposure
    name: pipeline_quality
    model: saas_qbr
    explore: qbr_performance
    type: looker_bar
    fields: [qbr_rep_performance.total_high_risk_arr, qbr_rep_performance.total_zombie_arr,
      qbr_rep_performance.total_questionable_commit_arr]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 11
    col: 16
    width: 8
    height: 8

  # -------------------------------------------------------------- detail
  - title: Scorecard Detail
    name: scorecard_detail
    model: saas_qbr
    explore: qbr_performance
    type: looker_grid
    fields: [qbr_rep_roster.rep_name, qbr_rep_roster.manager_name, qbr_rep_roster.segment,
      qbr_rep_quota.ramp_status, qbr_rep_quota.total_arr_quota, qbr_rep_performance.total_won_arr,
      qbr_rep_quota.arr_attainment, qbr_rep_quota.quota_gap, qbr_rep_performance.total_open_pipeline_arr,
      qbr_rep_quota.pipeline_coverage_ratio, qbr_rep_performance.win_rate, qbr_rep_performance.total_high_risk_arr]
    sorts: [qbr_rep_quota.arr_attainment desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: modern
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_row_alignment: left
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 19
    col: 0
    width: 24
    height: 9
