view: qbr_rep_quota {
  label: "Quota & Attainment"
  sql_table_name: `aragosalooker.saas_qbr.rep_quota` ;;

  dimension: rep_quarter_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.rep_id, "|", CAST(${TABLE}.quarter_start_date AS STRING)) ;;
  }

  dimension: rep_id {
    hidden: yes
    type: string
    sql: ${TABLE}.rep_id ;;
  }

  dimension: manager_id {
    hidden: yes
    type: string
    sql: ${TABLE}.manager_id ;;
  }

  dimension: fiscal_year {
    label: "Fiscal Year"
    description: "Fiscal year the quota applies to."
    type: number
    value_format_name: id
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_quarter {
    label: "Fiscal Quarter Number"
    description: "Quarter number, 1 through 4."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.fiscal_quarter ;;
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
    description: "First day of the quota quarter."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.quarter_start_date ;;
  }

  dimension: quarter_end_date {
    label: "Quarter End Date"
    description: "Last day of the quota quarter."
    type: date
    convert_tz: no
    datatype: date
    sql: ${TABLE}.quarter_end_date ;;
  }

  dimension: is_current_quarter {
    label: "Is Current Quarter"
    description: "Whether this row is the quarter in progress today."
    type: yesno
    sql: ${TABLE}.quarter_start_date = DATE_TRUNC(CURRENT_DATE(), QUARTER) ;;
  }

  dimension: is_trailing_four_quarters {
    label: "Is Trailing 4 Quarters"
    description: "Whether this quarter falls inside the trailing twelve months. The primary QBR window."
    type: yesno
    sql: ${TABLE}.quarter_start_date >  DATE_SUB(DATE_TRUNC(CURRENT_DATE(), QUARTER), INTERVAL 4 QUARTER)
     AND ${TABLE}.quarter_start_date <= DATE_TRUNC(CURRENT_DATE(), QUARTER) ;;
  }

  dimension: segment {
    label: "Segment (Quota)"
    description: "Segment the quota was set against."
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: region {
    label: "Region (Quota)"
    description: "Region the quota was set against."
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: ramp_status {
    label: "Ramp Status (Quarter)"
    description: "Whether the rep was ramping in this specific quarter."
    type: string
    sql: ${TABLE}.ramp_status ;;
  }

  dimension: ramp_factor {
    label: "Ramp Factor"
    description: "Multiplier applied to a full quota for reps still ramping. 0.50, 0.75 or 1.00."
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.ramp_factor ;;
  }

  dimension: arr_quota {
    label: "ARR Quota (Rep-Quarter)"
    description: "Recurring revenue quota assigned to this rep for this quarter."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.arr_quota ;;
  }

  dimension: nrr_quota {
    label: "Services Quota (Rep-Quarter)"
    description: "Non-recurring (services) revenue quota for this rep-quarter."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.nrr_quota ;;
  }

  dimension: pipeline_coverage_target {
    label: "Pipeline Coverage Target"
    description: "Required ratio of open pipeline to quota. Company standard is 3.0x."
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.pipeline_coverage_target ;;
  }

  # ------------------------------------------------------------------ measures

  measure: total_arr_quota {
    label: "ARR Quota"
    description: "Sum of recurring revenue quota across the selected reps and quarters."
    type: sum
    sql: ${arr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [qbr_rep_roster.rep_name, fiscal_quarter_label, arr_quota, qbr_rep_performance.total_won_arr, arr_attainment]
  }

  measure: total_nrr_quota {
    label: "Services Quota"
    description: "Sum of services revenue quota."
    type: sum
    sql: ${nrr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: total_quota {
    label: "Total Quota"
    description: "Recurring plus services quota."
    type: number
    sql: ${total_arr_quota} + ${total_nrr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: average_arr_quota {
    label: "Avg ARR Quota per Rep-Quarter"
    description: "Mean quarterly recurring quota carried."
    type: average
    sql: ${arr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: quota_carrying_reps {
    label: "Quota-Carrying Reps"
    description: "Distinct reps with an assigned quota in the selected period."
    type: count_distinct
    sql: ${rep_id} ;;
    value_format_name: decimal_0
  }

  # ---- attainment (requires qbr_rep_performance in the explore) ----

  measure: arr_attainment {
    label: "ARR Attainment %"
    description: "Closed-won recurring revenue divided by recurring quota."
    type: number
    sql: SAFE_DIVIDE(${qbr_rep_performance.total_won_arr}, NULLIF(${total_arr_quota}, 0)) ;;
    value_format_name: percent_0
    drill_fields: [qbr_rep_roster.rep_name, fiscal_quarter_label, arr_quota, qbr_rep_performance.total_won_arr, arr_attainment]
  }

  measure: quota_gap {
    label: "Quota Gap"
    description: "Closed-won recurring revenue minus quota. Negative means behind plan."
    type: number
    sql: ${qbr_rep_performance.total_won_arr} - ${total_arr_quota} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[<=-1000000]-$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: quota_remaining {
    label: "Quota Remaining"
    description: "Recurring revenue still needed to reach quota. Floored at zero."
    type: number
    sql: GREATEST(${total_arr_quota} - ${qbr_rep_performance.total_won_arr}, 0) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: pipeline_coverage_ratio {
    label: "Pipeline Coverage"
    description: "Open pipeline ARR divided by the quota still outstanding. Below 3.0x is a red flag."
    type: number
    sql: SAFE_DIVIDE(${qbr_rep_performance.total_open_pipeline_arr},
                     NULLIF(GREATEST(${total_arr_quota} - ${qbr_rep_performance.total_won_arr}, 0), 0)) ;;
    value_format: "0.0\"x\""
  }

  measure: reps_at_or_above_quota {
    label: "Reps At or Above Quota"
    description: "Count of reps whose closed-won recurring revenue met or beat their quota in the quarter."
    type: number
    sql: COUNT(DISTINCT IF(COALESCE(${qbr_rep_performance.won_arr}, 0) >= ${arr_quota}, ${rep_id}, NULL)) ;;
    value_format_name: decimal_0
  }

  measure: reps_below_quota {
    label: "Reps Below Quota"
    description: "Count of reps who finished the quarter short of their quota."
    type: number
    sql: COUNT(DISTINCT IF(COALESCE(${qbr_rep_performance.won_arr}, 0) <  ${arr_quota}, ${rep_id}, NULL)) ;;
    value_format_name: decimal_0
  }

  measure: percent_reps_at_quota {
    label: "% Reps At Quota"
    description: "Share of quota-carrying reps that hit their number."
    type: number
    sql: SAFE_DIVIDE(${reps_at_or_above_quota}, NULLIF(${quota_carrying_reps}, 0)) ;;
    value_format_name: percent_0
  }
}
