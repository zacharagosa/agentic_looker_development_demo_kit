view: qbr_rep_performance {
  label: "Rep Performance"
  sql_table_name: `aragosalooker.saas_qbr.rep_performance` ;;

  dimension: rep_quarter_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.rep_quarter_key ;;
  }

  dimension: rep_id {
    hidden: yes
    type: string
    sql: ${TABLE}.rep_id ;;
  }

  dimension_group: quarter_start {
    label: "Performance Quarter"
    description: "First day of the quarter the results belong to."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.quarter_start_date ;;
  }

  dimension: fiscal_quarter_label {
    label: "Performance Quarter Label"
    description: "Quarter label, e.g. 2026-Q3."
    type: string
    sql: ${TABLE}.fiscal_quarter_label ;;
  }

  # ---- row-level values, hidden but referenced by cross-view measures ----
  dimension: won_arr        { hidden: yes  type: number  sql: ${TABLE}.won_arr ;; }
  dimension: open_pipe_arr  { hidden: yes  type: number  sql: ${TABLE}.open_pipeline_arr ;; }

  dimension: avg_sales_cycle_days {
    label: "Avg Sales Cycle (Days)"
    description: "Mean days from creation to close for deals won in the quarter."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.avg_sales_cycle_days ;;
  }

  dimension: avg_slip_count {
    label: "Avg Close-Date Slips"
    description: "Mean number of times open deals in this quarter have had their close date pushed."
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.avg_slip_count ;;
  }

  dimension: avg_days_in_stage {
    label: "Avg Days in Current Stage"
    description: "Mean days open deals have sat in their present stage."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.avg_days_in_stage ;;
  }

  # ------------------------------------------------------------ revenue won

  measure: total_won_arr {
    label: "Closed Won ARR"
    description: "Recurring revenue from deals closed won in the quarter."
    type: sum
    sql: ${TABLE}.won_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [qbr_rep_roster.rep_name, fiscal_quarter_label, total_won_arr, won_deal_count, win_rate]
  }

  measure: total_won_nrr {
    label: "Closed Won Services"
    description: "Non-recurring (services) revenue from deals closed won in the quarter."
    type: sum
    sql: ${TABLE}.won_nrr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_won_bookings {
    label: "Total Bookings"
    description: "All revenue booked from closed-won deals, recurring plus services."
    type: sum
    sql: ${TABLE}.won_bookings ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_new_logo_arr {
    label: "New Logo ARR"
    description: "Recurring revenue won from New Business deals."
    type: sum
    sql: ${TABLE}.new_logo_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_expansion_arr {
    label: "Expansion ARR"
    description: "Recurring revenue won from existing customers."
    type: sum
    sql: ${TABLE}.expansion_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_lost_arr {
    label: "Lost ARR"
    description: "Recurring revenue on deals closed lost in the quarter."
    type: sum
    sql: ${TABLE}.lost_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  # ------------------------------------------------------------ deal counts

  measure: won_deal_count {
    label: "Deals Won"
    description: "Number of opportunities closed won."
    type: sum
    sql: ${TABLE}.won_deals ;;
    value_format_name: decimal_0
  }

  measure: lost_deal_count {
    label: "Deals Lost"
    description: "Number of opportunities closed lost."
    type: sum
    sql: ${TABLE}.lost_deals ;;
    value_format_name: decimal_0
  }

  measure: created_deal_count {
    label: "Deals Created"
    description: "Number of opportunities created in the quarter."
    type: sum
    sql: ${TABLE}.created_deals ;;
    value_format_name: decimal_0
  }

  measure: total_created_arr {
    label: "Pipeline Created ARR"
    description: "Recurring revenue value of opportunities created in the quarter."
    type: sum
    sql: ${TABLE}.created_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: win_rate {
    label: "Win Rate"
    description: "Deals won divided by all deals closed."
    type: number
    sql: SAFE_DIVIDE(${won_deal_count}, NULLIF(${won_deal_count} + ${lost_deal_count}, 0)) ;;
    value_format_name: percent_0
  }

  measure: average_won_deal_arr {
    label: "Avg Won Deal ARR"
    description: "Average recurring revenue per deal won."
    type: number
    sql: SAFE_DIVIDE(${total_won_arr}, NULLIF(${won_deal_count}, 0)) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: average_sales_cycle {
    label: "Avg Sales Cycle"
    description: "Mean days from opportunity creation to close, weighted across the selection."
    type: average
    sql: ${TABLE}.avg_sales_cycle_days ;;
    value_format: "0\" days\""
  }

  # ------------------------------------------------------------ open pipeline

  measure: total_open_pipeline_arr {
    label: "Open Pipeline ARR"
    description: "Recurring revenue on all open opportunities closing in the quarter."
    type: sum
    sql: ${TABLE}.open_pipeline_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: open_deal_count {
    label: "Open Deals"
    description: "Number of opportunities still open for the quarter."
    type: sum
    sql: ${TABLE}.open_deals ;;
    value_format_name: decimal_0
  }

  measure: total_commit_arr {
    label: "Commit ARR"
    description: "Recurring revenue the rep has placed in the Forecast (commit) category."
    type: sum
    sql: ${TABLE}.commit_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_upside_arr {
    label: "Upside ARR"
    description: "Recurring revenue in the Best Case / Upside category."
    type: sum
    sql: ${TABLE}.upside_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_early_pipeline_arr {
    label: "Early Pipeline ARR"
    description: "Recurring revenue in the early Pipeline category."
    type: sum
    sql: ${TABLE}.early_pipeline_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_omitted_arr {
    label: "Omitted ARR"
    description: "Recurring revenue the rep has excluded from the forecast entirely."
    type: sum
    sql: ${TABLE}.omitted_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  # ------------------------------------------------------------ deal quality

  measure: total_high_risk_arr {
    label: "High Risk Pipeline ARR"
    description: "Open pipeline scored High Risk by the deal quality model."
    type: sum
    sql: ${TABLE}.high_risk_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: high_risk_deal_count {
    label: "High Risk Deals"
    description: "Open opportunities scored High Risk."
    type: sum
    sql: ${TABLE}.high_risk_deals ;;
    value_format_name: decimal_0
  }

  measure: total_zombie_arr {
    label: "Zombie Deal ARR"
    description: "Pipeline on deals that have slipped four or more times and gone quiet for 90+ days."
    type: sum
    sql: ${TABLE}.zombie_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: zombie_deal_count {
    label: "Zombie Deals"
    description: "Count of repeatedly slipped, inactive opportunities."
    type: sum
    sql: ${TABLE}.zombie_deals ;;
    value_format_name: decimal_0
  }

  measure: total_questionable_commit_arr {
    label: "Questionable Commit ARR"
    description: "Revenue sitting in the commit forecast on deals stalled in stage for more than 56 days."
    type: sum
    sql: ${TABLE}.questionable_commit_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: questionable_commit_deal_count {
    label: "Questionable Commit Deals"
    description: "Commit-category deals that look nothing like commit deals."
    type: sum
    sql: ${TABLE}.questionable_commit_deals ;;
    value_format_name: decimal_0
  }

  measure: commit_quality_ratio {
    label: "Commit Quality"
    description: "Share of commit ARR that is NOT flagged as questionable. Higher is better."
    type: number
    sql: 1 - SAFE_DIVIDE(${total_questionable_commit_arr}, NULLIF(${total_commit_arr}, 0)) ;;
    value_format_name: percent_0
  }

  measure: total_activities {
    label: "Activities Logged"
    description: "Sales activities (calls, emails, meetings) logged in the quarter."
    type: sum
    sql: ${TABLE}.activities ;;
    value_format_name: decimal_0
  }

  measure: activities_per_won_deal {
    label: "Activities per Won Deal"
    description: "Sales effort required per closed-won deal."
    type: number
    sql: SAFE_DIVIDE(${total_activities}, NULLIF(${won_deal_count}, 0)) ;;
    value_format_name: decimal_1
  }
}
