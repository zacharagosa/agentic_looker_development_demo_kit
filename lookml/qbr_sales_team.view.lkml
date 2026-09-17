view: qbr_sales_team {
  label: "Team Plan"
  sql_table_name: `aragosalooker.saas_qbr.sales_team` ;;

  dimension: manager_quarter_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.manager_id, "|", CAST(${TABLE}.quarter_start_date AS STRING)) ;;
  }

  dimension: manager_id { hidden: yes  type: string  sql: ${TABLE}.manager_id ;; }

  dimension: manager_name {
    label: "Manager"
    description: "First-line sales manager who owns the team plan."
    type: string
    sql: ${TABLE}.manager_name ;;
  }

  dimension: manager_email {
    label: "Manager Email"
    description: "Work email for the manager."
    type: string
    sql: ${TABLE}.manager_email ;;
  }

  dimension: team_name {
    label: "Team"
    description: "Named sales team."
    type: string
    sql: ${TABLE}.team_name ;;
  }

  dimension: segment { label: "Segment" description: "Inside or Outside sales." type: string sql: ${TABLE}.segment ;; }
  dimension: region  { label: "Region"  description: "Sales region."             type: string sql: ${TABLE}.region ;; }

  dimension: fiscal_year {
    label: "Fiscal Year"
    description: "Fiscal year of the team plan."
    type: number
    value_format_name: id
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_quarter_label {
    label: "Fiscal Quarter"
    description: "Quarter label, e.g. 2026-Q3."
    type: string
    sql: ${TABLE}.fiscal_quarter_label ;;
    order_by_field: quarter_start_raw
  }

  dimension_group: quarter_start {
    label: "Quarter"
    description: "First day of the plan quarter."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.quarter_start_date ;;
  }

  dimension: is_current_quarter {
    label: "Is Current Quarter"
    description: "Whether this row is the quarter in progress today."
    type: yesno
    sql: ${TABLE}.quarter_start_date = DATE_TRUNC(CURRENT_DATE(), QUARTER) ;;
  }

  dimension: headcount {
    label: "Headcount"
    description: "Quota-carrying reps on the team this quarter."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.headcount ;;
  }

  dimension: team_arr_quota {
    label: "Team ARR Quota (Row)"
    description: "Team recurring quota for the quarter, including 5% over-assignment."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.team_arr_quota ;;
  }

  # ------------------------------------------------------------ measures

  measure: total_team_arr_quota {
    label: "Team ARR Quota"
    description: "Sum of team recurring quota, including 5% over-assignment over the rep roll-up."
    type: sum
    sql: ${TABLE}.team_arr_quota ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_team_nrr_quota {
    label: "Team Services Quota"
    description: "Sum of team services quota."
    type: sum
    sql: ${TABLE}.team_nrr_quota ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_headcount {
    label: "Quota-Carrying Headcount"
    description: "Reps carrying quota across the selection."
    type: sum
    sql: ${TABLE}.headcount ;;
    value_format_name: decimal_0
  }

  measure: fully_ramped_headcount {
    label: "Fully Ramped Headcount"
    description: "Reps past their ramp period."
    type: sum
    sql: ${TABLE}.fully_ramped_headcount ;;
    value_format_name: decimal_0
  }

  measure: manager_count {
    label: "Managers"
    description: "Distinct sales managers."
    type: count_distinct
    sql: ${manager_id} ;;
    value_format_name: decimal_0
  }

  measure: team_attainment {
    label: "Team Attainment %"
    description: "Team closed-won recurring revenue divided by team quota."
    type: number
    sql: SAFE_DIVIDE(${qbr_team_performance.total_won_arr}, NULLIF(${total_team_arr_quota}, 0)) ;;
    value_format_name: percent_0
  }

  measure: team_quota_gap {
    label: "Team Quota Gap"
    description: "Team bookings minus team quota. Negative means behind plan."
    type: number
    sql: ${qbr_team_performance.total_won_arr} - ${total_team_arr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[<=-1000000]-$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: team_pipeline_coverage {
    label: "Team Pipeline Coverage"
    description: "Open team pipeline divided by remaining team quota. Below 3.0x is a red flag."
    type: number
    sql: SAFE_DIVIDE(${qbr_team_performance.total_open_pipeline_arr},
                     NULLIF(GREATEST(${total_team_arr_quota} - ${qbr_team_performance.total_won_arr}, 0), 0)) ;;
    value_format: "0.0\"x\""
  }

  measure: quota_per_head {
    label: "Quota per Head"
    description: "Team quota divided by quota-carrying headcount."
    type: number
    sql: SAFE_DIVIDE(${total_team_arr_quota}, NULLIF(${total_headcount}, 0)) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }
}
