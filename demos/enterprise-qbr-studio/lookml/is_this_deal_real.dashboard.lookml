- dashboard: is_this_deal_real
  title: "Pipeline Integrity & Deal Execution Audit"
  description: "Executive audit of open pipeline quality: close-date push frequency, stage duration, activity recency, and forecast category alignment."
  layout: newspaper
  preferred_viewer: dashboards-next
  style: modern
  crossfilter_enabled: true
  filters:

  - name: Sales Rep
    title: Sales Rep
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_pipeline_inspection
    listens_to_filters: [Manager]
    field: qbr_rep_roster.rep_name

  - name: Manager
    title: Manager
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_pipeline_inspection
    listens_to_filters: []
    field: qbr_rep_roster.manager_name

  - name: Forecast Category
    title: Forecast Category
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: button_group, display: inline}
    model: saas_qbr
    explore: qbr_pipeline_inspection
    listens_to_filters: []
    field: qbr_deal_quality.forecast_category

  - name: Close Quarter
    title: Close Quarter
    type: field_filter
    default_value: 2 quarters
    allow_multiple_values: true
    required: false
    ui_config: {type: relative_timeframes, display: inline}
    model: saas_qbr
    explore: qbr_pipeline_inspection
    listens_to_filters: []
    field: qbr_deal_quality.close_date

  - name: Opportunity
    title: Opportunity
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: advanced, display: popover}
    model: saas_qbr
    explore: qbr_pipeline_inspection
    listens_to_filters: []
    field: qbr_deal_quality.opportunity_name

  elements:

  - title: Open Pipeline ARR
    name: d_kpi_open
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: single_value
    fields: [qbr_deal_quality.open_arr]
    filters:
      qbr_deal_quality.is_closed: 'No'
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Open Pipeline"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 0
    col: 0
    width: 5
    height: 3

  - title: High Risk ARR
    name: d_kpi_highrisk
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: single_value
    fields: [qbr_deal_quality.high_risk_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "High Risk ARR"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 0
    col: 5
    width: 5
    height: 3

  - title: "% Pipeline at High Risk"
    name: d_kpi_pct
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: single_value
    fields: [qbr_deal_quality.percent_high_risk_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "% High Risk"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 0
    col: 10
    width: 5
    height: 3

  - title: Stalled & Multi-Slip Opportunities
    name: d_kpi_zombie
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: single_value
    fields: [qbr_deal_quality.zombie_deal_count]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Stalled Opps"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 0
    col: 15
    width: 5
    height: 3

  - title: Questionable Commit ARR
    name: d_kpi_qcommit
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: single_value
    fields: [qbr_deal_quality.questionable_commit_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "At-Risk Commit"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 0
    col: 20
    width: 4
    height: 3

  - title: Commit Forecast vs. Deal Quality Score
    name: d_commit_check
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
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Close Quarter: qbr_deal_quality.close_date, Opportunity: qbr_deal_quality.opportunity_name}
    row: 3
    col: 0
    width: 12
    height: 8

  - title: Close-Date Slips
    name: d_slips
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_column
    fields: [qbr_deal_quality.slip_band, qbr_deal_quality.open_arr, qbr_deal_quality.open_deal_count]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.slip_band]
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
      qbr_deal_quality.open_deal_count: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_deal_quality.open_arr,
            id: qbr_deal_quality.open_arr, name: Open Pipeline ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_deal_quality.open_deal_count,
            id: qbr_deal_quality.open_deal_count, name: Open Deals}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 3
    col: 12
    width: 12
    height: 8

  - title: Stage Ageing
    name: d_stage_age
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_column
    fields: [qbr_deal_quality.stage_name, qbr_deal_quality.open_arr, qbr_deal_quality.average_days_in_stage]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.average_days_in_stage desc]
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
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 11
    col: 0
    width: 12
    height: 8

  - title: Risk Band Mix
    name: d_bands
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_donut_multiples
    fields: [qbr_deal_quality.risk_band, qbr_deal_quality.open_arr]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.risk_band]
    limit: 500
    show_view_names: false
    show_value_labels: true
    font_size: 12
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 11
    col: 12
    width: 12
    height: 8

  - title: Deal Inspection
    name: d_detail
    model: saas_qbr
    explore: qbr_pipeline_inspection
    type: looker_grid
    fields: [qbr_deal_quality.opportunity_name, qbr_rep_roster.rep_name, qbr_deal_quality.stage_name,
      qbr_deal_quality.forecast_category, qbr_deal_quality.probability, qbr_deal_quality.close_date,
      qbr_deal_quality.original_close_date, qbr_deal_quality.arr_amount, qbr_deal_quality.slip_count,
      qbr_deal_quality.days_in_current_stage, qbr_deal_quality.days_since_last_activity,
      qbr_deal_quality.contact_count, qbr_deal_quality.discount_depth, qbr_deal_quality.risk_score,
      qbr_deal_quality.risk_band]
    filters:
      qbr_deal_quality.is_closed: 'No'
    sorts: [qbr_deal_quality.risk_score desc]
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
    listen: {Sales Rep: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Forecast Category: qbr_deal_quality.forecast_category, Close Quarter: qbr_deal_quality.close_date,
      Opportunity: qbr_deal_quality.opportunity_name}
    row: 19
    col: 0
    width: 24
    height: 11
