- dashboard: team_qbr_rollup
  title: "Regional Team Performance & Quota Roll-Up"
  description: "How every rep on the team is tracking against plan, where the gap is, and which deals the manager should inspect."
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
    explore: qbr_team_rollup
    listens_to_filters: []
    field: qbr_sales_team.fiscal_quarter_label

  - name: Manager
    title: Manager
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_team_rollup
    listens_to_filters: []
    field: qbr_sales_team.manager_name

  - name: Segment
    title: Segment
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: button_group, display: inline}
    model: saas_qbr
    explore: qbr_team_rollup
    listens_to_filters: []
    field: qbr_sales_team.segment

  elements:

  - title: Team ARR Quota
    name: t_kpi_quota
    model: saas_qbr
    explore: qbr_team_rollup
    type: single_value
    fields: [qbr_sales_team.total_team_arr_quota]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Team Quota"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 0
    col: 0
    width: 5
    height: 3

  - title: Team Bookings
    name: t_kpi_won
    model: saas_qbr
    explore: qbr_team_rollup
    type: single_value
    fields: [qbr_team_performance.total_won_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Team Bookings"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 0
    col: 5
    width: 5
    height: 3

  - title: Team Attainment
    name: t_kpi_attainment
    model: saas_qbr
    explore: qbr_team_rollup
    type: single_value
    fields: [qbr_sales_team.team_attainment]
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
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 0
    col: 10
    width: 5
    height: 3

  - title: Team Quota Gap
    name: t_kpi_gap
    model: saas_qbr
    explore: qbr_team_rollup
    type: single_value
    fields: [qbr_sales_team.team_quota_gap]
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
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 0
    col: 15
    width: 5
    height: 3

  - title: Quota-Carrying Reps
    name: t_kpi_heads
    model: saas_qbr
    explore: qbr_team_rollup
    type: single_value
    fields: [qbr_sales_team.total_headcount]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Active Reps"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 0
    col: 20
    width: 4
    height: 3

  - title: Plan vs Actual by Manager
    name: t_plan_vs_actual
    model: saas_qbr
    explore: qbr_team_rollup
    type: looker_column
    fields: [qbr_sales_team.manager_name, qbr_sales_team.total_team_arr_quota, qbr_team_performance.total_won_arr,
      qbr_sales_team.team_attainment]
    sorts: [qbr_sales_team.team_attainment desc]
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
      qbr_sales_team.team_attainment: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_sales_team.total_team_arr_quota,
            id: qbr_sales_team.total_team_arr_quota, name: Team ARR Quota}, {axisId: qbr_team_performance.total_won_arr,
            id: qbr_team_performance.total_won_arr, name: Team Closed Won ARR}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_sales_team.team_attainment,
            id: qbr_sales_team.team_attainment, name: Team Attainment}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 3
    col: 0
    width: 13
    height: 9

  - title: Team Attainment Trend
    name: t_trend
    model: saas_qbr
    explore: qbr_team_rollup
    type: looker_line
    fields: [qbr_sales_team.fiscal_quarter_label, qbr_sales_team.manager_name, qbr_sales_team.team_attainment]
    pivots: [qbr_sales_team.manager_name]
    sorts: [qbr_sales_team.fiscal_quarter_label]
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
    y_axis_combined: true
    show_null_points: false
    interpolation: monotone
    y_axes: [{label: '', orientation: left, series: [], showLabels: false, showValues: true,
        unpinAxis: false, tickDensity: default, tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Manager: qbr_sales_team.manager_name, Segment: qbr_sales_team.segment}
    row: 3
    col: 13
    width: 11
    height: 9

  - title: Pipeline Coverage by Team
    name: t_coverage
    model: saas_qbr
    explore: qbr_team_rollup
    type: looker_bar
    fields: [qbr_sales_team.manager_name, qbr_sales_team.team_pipeline_coverage]
    sorts: [qbr_sales_team.team_pipeline_coverage]
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
    reference_lines: [{reference_type: line, range_start: max, range_end: min, margin_top: deviation,
        margin_value: mean, margin_bottom: deviation, label_position: right, color: "#B3261E",
        line_value: '3', label: 3.0x target}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 12
    col: 0
    width: 8
    height: 8

  - title: Team Pipeline Quality
    name: t_quality
    model: saas_qbr
    explore: qbr_team_rollup
    type: looker_bar
    fields: [qbr_sales_team.manager_name, qbr_team_performance.total_commit_arr, qbr_team_performance.total_questionable_commit_arr]
    sorts: [qbr_team_performance.total_commit_arr desc]
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
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    y_axes: [{label: '', orientation: bottom, series: [{axisId: qbr_team_performance.total_commit_arr,
            id: qbr_team_performance.total_commit_arr, name: Team Commit ARR}, {axisId: qbr_team_performance.total_questionable_commit_arr,
            id: qbr_team_performance.total_questionable_commit_arr, name: Team Questionable Commit ARR}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 12
    col: 8
    width: 8
    height: 8

  - title: Reps Producing vs Headcount
    name: t_producing
    model: saas_qbr
    explore: qbr_team_rollup
    type: looker_column
    fields: [qbr_sales_team.manager_name, qbr_sales_team.total_headcount, qbr_team_performance.reps_producing]
    sorts: [qbr_sales_team.total_headcount desc]
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
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_sales_team.total_headcount,
            id: qbr_sales_team.total_headcount, name: Quota-Carrying Headcount}, {
            axisId: qbr_team_performance.reps_producing, id: qbr_team_performance.reps_producing,
            name: Reps Producing}], showLabels: false, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Quarter: qbr_sales_team.fiscal_quarter_label, Manager: qbr_sales_team.manager_name,
      Segment: qbr_sales_team.segment}
    row: 12
    col: 16
    width: 8
    height: 8

  - title: Rep Leaderboard
    name: t_leaderboard
    model: saas_qbr
    explore: qbr_performance
    type: looker_grid
    fields: [qbr_rep_roster.rep_name, qbr_rep_roster.manager_name, qbr_rep_roster.segment,
      qbr_rep_roster.region, qbr_rep_quota.ramp_status, qbr_rep_quota.total_arr_quota,
      qbr_rep_performance.total_won_arr, qbr_rep_quota.arr_attainment, qbr_rep_quota.quota_gap,
      qbr_rep_performance.total_open_pipeline_arr, qbr_rep_performance.win_rate, qbr_rep_performance.total_high_risk_arr,
      qbr_rep_performance.total_activities]
    filters:
      qbr_rep_quota.fiscal_quarter_label: 2026-Q3
    sorts: [qbr_rep_quota.arr_attainment desc]
    limit: 500
    show_view_names: false
    show_row_numbers: true
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
    listen: {Manager: qbr_rep_roster.manager_name, Segment: qbr_rep_roster.segment}
    row: 20
    col: 0
    width: 24
    height: 10
