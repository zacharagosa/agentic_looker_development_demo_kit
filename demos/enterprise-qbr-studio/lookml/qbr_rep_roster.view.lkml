view: qbr_rep_roster {
  label: "Sales Rep"
  sql_table_name: `aragosalooker.saas_qbr.rep_roster` ;;

  dimension: rep_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.rep_id ;;
  }

  dimension: rep_name {
    label: "Rep Name"
    description: "Full name of the account executive."
    type: string
    sql: ${TABLE}.rep_name ;;
    drill_fields: [qbr_deal_quality.opportunity_name, qbr_deal_quality.stage_name, qbr_deal_quality.arr_amount, qbr_deal_quality.risk_band]
  }

  dimension: first_name {
    hidden: yes
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    hidden: yes
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: email {
    label: "Rep Email"
    description: "Work email for the rep. Used to route QBR decks."
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: role_name {
    label: "Role"
    description: "Salesforce role title, e.g. Account Executive."
    type: string
    sql: ${TABLE}.role_name ;;
  }

  dimension: segment {
    label: "Segment"
    description: "Inside or Outside sales segment."
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: region {
    label: "Region"
    description: "Sales region: East, West or UK-Europe."
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: segment_region {
    label: "Segment + Region"
    description: "Combined segment and region, e.g. Inside - East."
    type: string
    sql: ${TABLE}.segment_region ;;
  }

  dimension: manager_id {
    hidden: yes
    type: string
    sql: ${TABLE}.manager_id ;;
  }

  dimension: manager_name {
    label: "Manager"
    description: "Name of the rep's first-line sales manager."
    type: string
    sql: ${TABLE}.manager_name ;;
    drill_fields: [rep_name, qbr_rep_quota.arr_quota, qbr_rep_performance.total_won_arr, qbr_rep_quota.arr_attainment]
  }

  dimension: manager_email {
    label: "Manager Email"
    description: "Work email for the rep's manager."
    type: string
    sql: ${TABLE}.manager_email ;;
  }

  dimension: manager_role {
    hidden: yes
    type: string
    sql: ${TABLE}.manager_role ;;
  }

  dimension: team_name {
    label: "Team"
    description: "Named sales team, derived from the manager."
    type: string
    sql: ${TABLE}.team_name ;;
  }

  dimension: is_active {
    label: "Is Active"
    description: "Whether the rep is currently employed and carrying a bag."
    type: yesno
    sql: ${TABLE}.is_active ;;
  }

  dimension_group: hire {
    label: "Hire"
    description: "Date the rep was hired."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.hire_date ;;
  }

  dimension_group: quota_start {
    label: "Quota Start"
    description: "Date the rep began carrying quota."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.quota_start_date ;;
  }

  dimension: tenure_months {
    label: "Tenure (Months)"
    description: "Months since the rep's hire date."
    type: number
    sql: ${TABLE}.tenure_months ;;
  }

  dimension: tenure_band {
    label: "Tenure Band"
    description: "Bucketed tenure, useful for comparing like-for-like reps."
    type: string
    sql: CASE
           WHEN ${tenure_months} < 6  THEN "0-6 months"
           WHEN ${tenure_months} < 12 THEN "6-12 months"
           WHEN ${tenure_months} < 24 THEN "1-2 years"
           ELSE "2+ years"
         END ;;
  }

  dimension: ramp_status {
    label: "Ramp Status"
    description: "Ramping, Partial Ramp or Fully Ramped based on quota start date."
    type: string
    sql: ${TABLE}.ramp_status ;;
  }

  measure: rep_count {
    label: "Rep Count"
    description: "Distinct account executives."
    type: count_distinct
    sql: ${rep_id} ;;
    value_format_name: decimal_0
    drill_fields: [rep_name, manager_name, segment, region, ramp_status]
  }

  measure: active_rep_count {
    label: "Active Rep Count"
    description: "Distinct account executives currently employed."
    type: count_distinct
    sql: ${rep_id} ;;
    filters: [is_active: "yes"]
    value_format_name: decimal_0
  }

  measure: manager_count {
    label: "Manager Count"
    description: "Distinct first-line sales managers."
    type: count_distinct
    sql: ${manager_id} ;;
    value_format_name: decimal_0
  }
}
