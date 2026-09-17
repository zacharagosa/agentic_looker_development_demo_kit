- dashboard: why_am_i_missing_quota
  title: "Quota Attainment & Pipeline Velocity Diagnostics"
  description: "Diagnostic analysis of pipeline volume, conversion velocity, sales cycle duration, and activity efficiency."
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
    listens_to_filters: [Manager]
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

  elements:

  - title: Quota Gap
    name: w_kpi_gap
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
      Manager: qbr_rep_roster.manager_name}
    row: 0
    col: 0
    width: 5
    height: 3

  - title: Pipeline Coverage
    name: w_kpi_coverage
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
      Manager: qbr_rep_roster.manager_name}
    row: 0
    col: 5
    width: 5
    height: 3

  - title: Win Rate
    name: w_kpi_winrate
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_performance.win_rate]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Win Rate"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name}
    row: 0
    col: 10
    width: 5
    height: 3

  - title: Avg Sales Cycle
    name: w_kpi_cycle
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_performance.average_sales_cycle]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Sales Cycle"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name}
    row: 0
    col: 15
    width: 5
    height: 3

  - title: Activities per Won Deal
    name: w_kpi_activity
    model: saas_qbr
    explore: qbr_performance
    type: single_value
    fields: [qbr_rep_performance.activities_per_won_deal]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Activities / Won"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_rep_quota.fiscal_quarter_label, Sales Rep: qbr_rep_roster.rep_name,
      Manager: qbr_rep_roster.manager_name}
    row: 0
    col: 20
    width: 4
    height: 3

  - title: Pipeline Created vs Revenue Won
    name: w_created_vs_won
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_quota.fiscal_quarter_label, qbr_rep_performance.total_created_arr,
      qbr_rep_performance.total_won_arr, qbr_rep_performance.win_rate]
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
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_rep_performance.total_created_arr,
            id: qbr_rep_performance.total_created_arr, name: Pipeline Created ARR},
          {axisId: qbr_rep_performance.total_won_arr, id: qbr_rep_performance.total_won_arr,
            name: Closed Won ARR}], showLabels: false, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: '', orientation: right,
        series: [{axisId: qbr_rep_performance.win_rate, id: qbr_rep_performance.win_rate,
            name: Win Rate}], showLabels: false, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name}
    row: 3
    col: 0
    width: 12
    height: 8

  - title: Won vs Lost Deals
    name: w_won_lost
    model: saas_qbr
    explore: qbr_performance
    type: looker_column
    fields: [qbr_rep_quota.fiscal_quarter_label, qbr_rep_performance.won_deal_count,
      qbr_rep_performance.lost_deal_count, qbr_rep_performance.average_won_deal_arr]
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
      qbr_rep_performance.average_won_deal_arr: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_rep_performance.won_deal_count,
            id: qbr_rep_performance.won_deal_count, name: Deals Won}, {axisId: qbr_rep_performance.lost_deal_count,
            id: qbr_rep_performance.lost_deal_count, name: Deals Lost}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_rep_performance.average_won_deal_arr,
            id: qbr_rep_performance.average_won_deal_arr, name: Avg Won Deal ARR}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name}
    row: 3
    col: 12
    width: 12
    height: 8

  - title: Pipeline Stage Duration & Velocity Bottlenecks
    name: w_stuck
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_column
    fields: [qbr_deal_quality.stage_name, qbr_deal_quality.open_arr, qbr_deal_quality.average_days_in_stage]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.open_arr desc]
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
      qbr_deal_quality.average_days_in_stage: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_deal_quality.open_arr,
            id: qbr_deal_quality.open_arr, name: Open Pipeline ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_deal_quality.average_days_in_stage,
            id: qbr_deal_quality.average_days_in_stage, name: Avg Days in Stage}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name}
    row: 11
    col: 0
    width: 12
    height: 8

  - title: Pipeline Integrity by Quality Tier
    name: w_real
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_column
    fields: [qbr_deal_quality.forecast_category, qbr_deal_quality.open_arr, qbr_deal_quality.high_risk_arr,
      qbr_deal_quality.percent_high_risk_arr]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.open_arr desc]
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
      qbr_deal_quality.percent_high_risk_arr: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_deal_quality.open_arr,
            id: qbr_deal_quality.open_arr, name: Open Pipeline ARR}, {axisId: qbr_deal_quality.high_risk_arr,
            id: qbr_deal_quality.high_risk_arr, name: High Risk ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_deal_quality.percent_high_risk_arr,
            id: qbr_deal_quality.percent_high_risk_arr, name: '% Pipeline at High Risk'}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name}
    row: 11
    col: 12
    width: 12
    height: 8

  - title: Deals That Need Attention
    name: w_attention
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_grid
    fields: [qbr_deal_quality.opportunity_name, qbr_rep_roster.rep_name, qbr_deal_quality.stage_name,
      qbr_deal_quality.forecast_category, qbr_deal_quality.close_date, qbr_deal_quality.arr_amount,
      qbr_deal_quality.slip_count, qbr_deal_quality.days_in_current_stage, qbr_deal_quality.days_since_last_activity,
      qbr_deal_quality.contact_count, qbr_deal_quality.risk_score, qbr_deal_quality.risk_band]
    filters:
      qbr_deal_quality.is_closed: 'No'
      qbr_deal_quality.risk_band: High Risk,Medium Risk
    sorts: [qbr_deal_quality.arr_amount desc]
    limit: 100
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
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name}
    row: 19
    col: 0
    width: 24
    height: 10
