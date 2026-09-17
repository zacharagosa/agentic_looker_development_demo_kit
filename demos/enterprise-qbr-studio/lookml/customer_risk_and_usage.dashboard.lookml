- dashboard: customer_risk_and_usage
  title: "Account Health, Adoption & Renewal Risk"
  description: "Which customers are likely to churn and why — seat utilization, usage trend, support load, CSAT and renewal timing, with the ARR exposed."
  layout: newspaper
  preferred_viewer: dashboards-next
  style: modern
  crossfilter_enabled: true
  filters:

  - name: Account Owner
    title: Account Owner
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_customer_risk
    listens_to_filters: [Manager]
    field: qbr_rep_roster.rep_name

  - name: Manager
    title: Manager
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_customer_risk
    listens_to_filters: []
    field: qbr_rep_roster.manager_name

  - name: Risk Band
    title: Risk Band
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: button_group, display: inline}
    model: saas_qbr
    explore: qbr_customer_risk
    listens_to_filters: []
    field: qbr_account_risk.risk_band

  - name: Industry
    title: Industry
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config: {type: dropdown_menu, display: inline}
    model: saas_qbr
    explore: qbr_customer_risk
    listens_to_filters: []
    field: qbr_account_risk.industry

  elements:

  - title: Customer ARR
    name: c_kpi_arr
    model: saas_qbr
    explore: qbr_customer_risk
    type: single_value
    fields: [qbr_account_risk.total_active_arr]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Customer ARR"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 0
    col: 0
    width: 5
    height: 3

  - title: ARR at Risk
    name: c_kpi_atrisk
    model: saas_qbr
    explore: qbr_customer_risk
    type: single_value
    fields: [qbr_account_risk.total_arr_at_risk]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "ARR at Risk"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 0
    col: 5
    width: 5
    height: 3

  - title: "% ARR at Risk"
    name: c_kpi_pct
    model: saas_qbr
    explore: qbr_customer_risk
    type: single_value
    fields: [qbr_account_risk.percent_arr_at_risk]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "% ARR at Risk"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 0
    col: 10
    width: 5
    height: 3

  - title: High Risk Accounts
    name: c_kpi_count
    model: saas_qbr
    explore: qbr_customer_risk
    type: single_value
    fields: [qbr_account_risk.high_risk_account_count]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "High-Risk Accts"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 0
    col: 15
    width: 5
    height: 3

  - title: Avg Seat Utilization
    name: c_kpi_util
    model: saas_qbr
    explore: qbr_customer_risk
    type: single_value
    fields: [qbr_account_risk.average_utilization]
    limit: 500
    custom_color_enabled: false
    show_single_value_title: true
    single_value_title: "Seat Utilization"
    show_comparison: false
    enable_conditional_formatting: false
    smart_single_value_size: true
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 0
    col: 20
    width: 4
    height: 3

  - title: Seat Utilization Drives Churn Risk
    name: c_util
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_column
    fields: [qbr_account_risk.utilization_band, qbr_account_risk.total_arr_at_risk,
      qbr_account_risk.account_count]
    sorts: [qbr_account_risk.utilization_band]
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
      qbr_account_risk.account_count: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_account_risk.total_arr_at_risk,
            id: qbr_account_risk.total_arr_at_risk, name: ARR at Risk}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_account_risk.account_count,
            id: qbr_account_risk.account_count, name: Accounts}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 3
    col: 0
    width: 12
    height: 8

  - title: Renewal Exposure
    name: c_renewal
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_column
    fields: [qbr_account_risk.renewal_window, qbr_account_risk.total_active_arr, qbr_account_risk.total_arr_at_risk,
      qbr_account_risk.percent_arr_at_risk]
    sorts: [qbr_account_risk.renewal_window]
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
      qbr_account_risk.percent_arr_at_risk: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_account_risk.total_active_arr,
            id: qbr_account_risk.total_active_arr, name: Customer ARR}, {axisId: qbr_account_risk.total_arr_at_risk,
            id: qbr_account_risk.total_arr_at_risk, name: ARR at Risk}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}, {label: '', orientation: right, series: [{axisId: qbr_account_risk.percent_arr_at_risk,
            id: qbr_account_risk.percent_arr_at_risk, name: '% ARR at Risk'}], showLabels: false,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 3
    col: 12
    width: 12
    height: 8

  - title: What Is Driving the Risk
    name: c_drivers
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_bar
    fields: [qbr_account_risk.risk_band, qbr_account_risk.average_risk_score]
    sorts: [qbr_account_risk.risk_band]
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
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 11
    col: 0
    width: 8
    height: 8

  - title: Risk by Industry
    name: c_industry
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_bar
    fields: [qbr_account_risk.industry, qbr_account_risk.total_arr_at_risk]
    sorts: [qbr_account_risk.total_arr_at_risk desc]
    limit: 12
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
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band}
    row: 11
    col: 8
    width: 8
    height: 8

  - title: Support Load vs Satisfaction
    name: c_support
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_column
    fields: [qbr_account_risk.risk_band, qbr_account_risk.total_tickets_90d, qbr_account_risk.average_csat]
    sorts: [qbr_account_risk.risk_band]
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
      qbr_account_risk.average_csat: line
    y_axes: [{label: '', orientation: left, series: [{axisId: qbr_account_risk.total_tickets_90d,
            id: qbr_account_risk.total_tickets_90d, name: Support Tickets (90d)}],
        showLabels: false, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}, {label: '', orientation: right, series: [
          {axisId: qbr_account_risk.average_csat, id: qbr_account_risk.average_csat,
            name: Avg CSAT}], showLabels: false, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    modern2026: true
    collection_id: looker_2026
    defaults_version: 1
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Risk Band: qbr_account_risk.risk_band, Industry: qbr_account_risk.industry}
    row: 11
    col: 16
    width: 8
    height: 8

  - title: Accounts Needing Intervention
    name: c_detail
    model: saas_qbr
    explore: qbr_customer_risk
    type: looker_grid
    fields: [qbr_account_risk.account_name, qbr_rep_roster.rep_name, qbr_account_risk.industry,
      qbr_account_risk.active_arr, qbr_account_risk.named_users, qbr_account_risk.active_users_30d,
      qbr_account_risk.utilization_pct, qbr_account_risk.usage_trend_pct, qbr_account_risk.tickets_90d,
      qbr_account_risk.avg_csat_180d, qbr_account_risk.next_renewal_date, qbr_account_risk.days_to_renewal,
      qbr_account_risk.risk_score, qbr_account_risk.risk_band]
    filters:
      qbr_account_risk.risk_band: High Risk,Watch
    sorts: [qbr_account_risk.risk_score desc]
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
    listen: {Account Owner: qbr_rep_roster.rep_name, Manager: qbr_rep_roster.manager_name,
      Industry: qbr_account_risk.industry}
    row: 19
    col: 0
    width: 24
    height: 11
