view: qbr_team_performance {
  label: "Team Performance"
  sql_table_name: `aragosalooker.saas_qbr.team_performance` ;;

  dimension: manager_quarter_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.manager_quarter_key ;;
  }

  dimension: manager_id { hidden: yes type: string sql: ${TABLE}.manager_id ;; }

  dimension_group: quarter_start {
    label: "Performance Quarter"
    description: "First day of the quarter the team results belong to."
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

  measure: total_won_arr {
    label: "Team Closed Won ARR"
    description: "Recurring revenue the team closed in the quarter."
    type: sum
    sql: ${TABLE}.won_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_won_nrr {
    label: "Team Closed Won Services"
    description: "Services revenue the team closed in the quarter."
    type: sum
    sql: ${TABLE}.won_nrr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_new_logo_arr {
    label: "Team New Logo ARR"
    description: "Recurring revenue won from New Business deals."
    type: sum
    sql: ${TABLE}.new_logo_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_expansion_arr {
    label: "Team Expansion ARR"
    description: "Recurring revenue won from existing customers."
    type: sum
    sql: ${TABLE}.expansion_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_open_pipeline_arr {
    label: "Team Open Pipeline ARR"
    description: "Open recurring pipeline closing in the quarter."
    type: sum
    sql: ${TABLE}.open_pipeline_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_commit_arr {
    label: "Team Commit ARR"
    description: "Pipeline the team has placed in the commit forecast."
    type: sum
    sql: ${TABLE}.commit_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_upside_arr {
    label: "Team Upside ARR"
    description: "Pipeline in the Best Case / Upside category."
    type: sum
    sql: ${TABLE}.upside_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_high_risk_arr {
    label: "Team High Risk ARR"
    description: "Open pipeline scored High Risk by the deal quality model."
    type: sum
    sql: ${TABLE}.high_risk_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_zombie_arr {
    label: "Team Zombie ARR"
    description: "Pipeline on deals that have slipped repeatedly and gone quiet."
    type: sum
    sql: ${TABLE}.zombie_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_questionable_commit_arr {
    label: "Team Questionable Commit ARR"
    description: "Commit revenue on deals that are stalled in stage."
    type: sum
    sql: ${TABLE}.questionable_commit_arr ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: won_deal_count {
    label: "Team Deals Won"
    description: "Opportunities the team closed won."
    type: sum
    sql: ${TABLE}.won_deals ;;
    value_format_name: decimal_0
  }

  measure: lost_deal_count {
    label: "Team Deals Lost"
    description: "Opportunities the team closed lost."
    type: sum
    sql: ${TABLE}.lost_deals ;;
    value_format_name: decimal_0
  }

  measure: win_rate {
    label: "Team Win Rate"
    description: "Deals won divided by all deals closed."
    type: number
    sql: SAFE_DIVIDE(${won_deal_count}, NULLIF(${won_deal_count} + ${lost_deal_count}, 0)) ;;
    value_format_name: percent_0
  }

  measure: reps_producing {
    label: "Reps Producing"
    description: "Reps on the team who booked at least one deal in the quarter."
    type: sum
    sql: ${TABLE}.reps_producing ;;
    value_format_name: decimal_0
  }

  measure: reps_with_activity {
    label: "Reps with Activity"
    description: "Reps on the team with any opportunity movement in the quarter."
    type: sum
    sql: ${TABLE}.reps_with_activity ;;
    value_format_name: decimal_0
  }

  measure: average_sales_cycle {
    label: "Team Avg Sales Cycle"
    description: "Mean days from creation to close on won deals."
    type: average
    sql: ${TABLE}.avg_sales_cycle_days ;;
    value_format: "0\" days\""
  }
}
