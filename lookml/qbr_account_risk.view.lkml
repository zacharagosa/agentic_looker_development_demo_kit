view: qbr_account_risk {
  label: "Customer Risk"
  sql_table_name: `aragosalooker.saas_qbr.account_risk_score` ;;

  dimension: account_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.account_id ;;
  }

  dimension: rep_id { hidden: yes  type: string  sql: ${TABLE}.rep_id ;; }
  dimension: csm_id { hidden: yes  type: string  sql: ${TABLE}.csm_id ;; }
  dimension: client_id { hidden: yes  type: string  sql: ${TABLE}.client_id ;; }

  dimension: account_name {
    label: "Account"
    description: "Customer account name."
    type: string
    sql: ${TABLE}.account_name ;;
    drill_fields: [industry, active_arr, utilization_pct, usage_trend_pct, tickets_90d, risk_score, risk_band]
  }

  dimension: account_type {
    label: "Account Type"
    description: "Salesforce account type. This view is restricted to Customers."
    type: string
    sql: ${TABLE}.account_type ;;
  }

  dimension: industry {
    label: "Industry"
    description: "Customer industry."
    type: string
    sql: ${TABLE}.industry ;;
  }

  dimension: number_of_employees {
    label: "Employees"
    description: "Employee headcount at the customer."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.number_of_employees ;;
  }

  dimension: company_size_band {
    label: "Company Size"
    description: "Bucketed employee headcount."
    type: string
    sql: CASE
           WHEN ${TABLE}.number_of_employees IS NULL   THEN "Unknown"
           WHEN ${TABLE}.number_of_employees < 100     THEN "1-99"
           WHEN ${TABLE}.number_of_employees < 500     THEN "100-499"
           WHEN ${TABLE}.number_of_employees < 2000    THEN "500-1,999"
           ELSE "2,000+"
         END ;;
  }

  # ------------------------------------------------------------ renewal

  dimension_group: next_renewal {
    label: "Next Renewal"
    description: "Date the customer's contract comes up for renewal."
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.next_renewal_date ;;
  }

  dimension: days_to_renewal {
    label: "Days to Renewal"
    description: "Days until the contract renews. Negative means already past."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.days_to_renewal ;;
  }

  dimension: renewal_window {
    label: "Renewal Window"
    description: "How soon the renewal lands."
    type: string
    sql: CASE
           WHEN ${TABLE}.days_to_renewal IS NULL THEN "Unknown"
           WHEN ${TABLE}.days_to_renewal < 0     THEN "Overdue"
           WHEN ${TABLE}.days_to_renewal <= 90   THEN "Next 90 days"
           WHEN ${TABLE}.days_to_renewal <= 180  THEN "91-180 days"
           WHEN ${TABLE}.days_to_renewal <= 365  THEN "181-365 days"
           ELSE "Beyond 12 months"
         END ;;
    order_by_field: renewal_window_sort
  }

  dimension: renewal_window_sort {
    hidden: yes
    type: number
    sql: CASE
           WHEN ${TABLE}.days_to_renewal IS NULL THEN 9
           WHEN ${TABLE}.days_to_renewal < 0     THEN 1
           WHEN ${TABLE}.days_to_renewal <= 90   THEN 2
           WHEN ${TABLE}.days_to_renewal <= 180  THEN 3
           WHEN ${TABLE}.days_to_renewal <= 365  THEN 4
           ELSE 5
         END ;;
  }

  dimension: renews_within_180_days {
    label: "Renews Within 180 Days"
    description: "Whether the contract renews in the next six months."
    type: yesno
    sql: ${TABLE}.days_to_renewal IS NOT NULL AND ${TABLE}.days_to_renewal BETWEEN 0 AND 180 ;;
  }

  # ------------------------------------------------------------ product usage

  dimension: named_users {
    label: "Licensed Users"
    description: "Average licensed (named) seats over the last 30 days."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.named_users ;;
  }

  dimension: active_users_30d {
    label: "Active Users (30d)"
    description: "Average trailing-28-day active users over the last 30 days."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.active_users_30d ;;
  }

  dimension: active_users_prior_30d {
    label: "Active Users (Prior 30d)"
    description: "Average active users in the 30 days before that, for trend comparison."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.active_users_prior_30d ;;
  }

  dimension: utilization_pct {
    label: "Seat Utilization"
    description: "Active users divided by licensed seats. Low utilization is the strongest churn signal."
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.utilization_pct ;;
  }

  dimension: utilization_band {
    label: "Utilization Band"
    description: "Bucketed seat utilization."
    type: string
    sql: CASE
           WHEN ${TABLE}.utilization_pct IS NULL  THEN "No usage data"
           WHEN ${TABLE}.utilization_pct < 0.25   THEN "Under 25%"
           WHEN ${TABLE}.utilization_pct < 0.50   THEN "25-49%"
           WHEN ${TABLE}.utilization_pct < 0.75   THEN "50-74%"
           ELSE "75%+"
         END ;;
    order_by_field: utilization_band_sort
  }

  dimension: utilization_band_sort {
    hidden: yes
    type: number
    sql: CASE
           WHEN ${TABLE}.utilization_pct IS NULL THEN 9
           WHEN ${TABLE}.utilization_pct < 0.25  THEN 1
           WHEN ${TABLE}.utilization_pct < 0.50  THEN 2
           WHEN ${TABLE}.utilization_pct < 0.75  THEN 3
           ELSE 4
         END ;;
  }

  dimension: usage_trend_pct {
    label: "Usage Trend"
    description: "Change in active users versus the prior 30 days."
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.usage_trend_pct ;;
  }

  dimension: is_usage_declining {
    label: "Usage Declining"
    description: "Active users have fallen more than 10% month over month."
    type: yesno
    sql: ${TABLE}.usage_trend_pct < -0.10 ;;
  }

  dimension: usage_concentration {
    label: "Usage Concentration"
    description: "Share of activity driven by the top users. High concentration means the account depends on a few champions."
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.usage_concentration ;;
  }

  dimension: last_usage_date {
    label: "Last Usage Date"
    description: "Most recent day the account generated product usage."
    type: date
    convert_tz: no
    datatype: date
    sql: ${TABLE}.last_usage_date ;;
  }

  # ------------------------------------------------------------ support

  dimension: tickets_90d {
    label: "Support Tickets (90d)"
    description: "Zendesk tickets raised in the last 90 days."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.tickets_90d ;;
  }

  dimension: urgent_tickets_90d {
    label: "Urgent Tickets (90d)"
    description: "High or urgent priority tickets in the last 90 days."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.urgent_tickets_90d ;;
  }

  dimension: avg_csat_180d {
    label: "CSAT (180d)"
    description: "Average satisfaction rating on a one-to-five scale over the last 180 days."
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.avg_csat_180d ;;
  }

  # ------------------------------------------------------------ revenue

  dimension: active_arr {
    label: "Account ARR"
    description: "Active recurring revenue on the account."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.active_arr ;;
  }

  dimension: arr_at_risk_value {
    hidden: yes
    type: number
    sql: ${TABLE}.arr_at_risk ;;
  }

  # ------------------------------------------------------------ scoring

  dimension: risk_score {
    label: "Account Risk Score"
    description: "Zero to 100. Combines seat utilization, usage trend, support load, CSAT and renewal proximity."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.risk_score ;;
  }

  dimension: risk_band {
    label: "Account Risk Band"
    description: "Healthy under 34, Watch 34 to 45, High Risk 46 and above."
    type: string
    sql: ${TABLE}.risk_band ;;
    order_by_field: risk_band_sort
    html:
      {% if value == 'High Risk' %}<span style="color:#B3261E;font-weight:600;">{{ value }}</span>
      {% elsif value == 'Watch' %}<span style="color:#B26A00;font-weight:600;">{{ value }}</span>
      {% else %}<span style="color:#146C2E;font-weight:600;">{{ value }}</span>{% endif %} ;;
  }

  dimension: risk_band_sort {
    hidden: yes
    type: number
    sql: CASE ${TABLE}.risk_band WHEN "High Risk" THEN 1 WHEN "Watch" THEN 2 ELSE 3 END ;;
  }

  dimension: score_utilization { group_label: "Risk Drivers" label: "Utilization Points"  description: "Risk points from low seat utilization (max 30)." type: number value_format_name: decimal_1 sql: ${TABLE}.score_utilization ;; }
  dimension: score_usage_trend { group_label: "Risk Drivers" label: "Usage Trend Points"  description: "Risk points from declining usage (max 25)."      type: number value_format_name: decimal_1 sql: ${TABLE}.score_usage_trend ;; }
  dimension: score_support     { group_label: "Risk Drivers" label: "Support Points"      description: "Risk points from support ticket load (max 20)."  type: number value_format_name: decimal_1 sql: ${TABLE}.score_support ;; }
  dimension: score_csat        { group_label: "Risk Drivers" label: "CSAT Points"         description: "Risk points from poor satisfaction (max 15)."    type: number value_format_name: decimal_1 sql: ${TABLE}.score_csat ;; }
  dimension: score_renewal     { group_label: "Risk Drivers" label: "Renewal Points"      description: "Risk points from renewal proximity (max 10)."    type: number value_format_name: decimal_1 sql: ${TABLE}.score_renewal ;; }

  # ------------------------------------------------------------ measures

  measure: account_count {
    label: "Accounts"
    description: "Number of customer accounts."
    type: count
    drill_fields: [detail*]
  }

  measure: at_risk_account_count {
    label: "At-Risk Accounts"
    description: "Accounts scored Watch or High Risk."
    type: count
    filters: [risk_band: "Watch,High Risk"]
    drill_fields: [detail*]
  }

  measure: high_risk_account_count {
    label: "High Risk Accounts"
    description: "Accounts scored High Risk."
    type: count
    filters: [risk_band: "High Risk"]
    drill_fields: [detail*]
  }

  measure: total_active_arr {
    label: "Customer ARR"
    description: "Total active recurring revenue across the selected accounts."
    type: sum
    sql: ${active_arr} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: total_arr_at_risk {
    label: "ARR at Risk"
    description: "Recurring revenue on accounts scored Watch or High Risk."
    type: sum
    sql: ${arr_at_risk_value} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: percent_arr_at_risk {
    label: "% ARR at Risk"
    description: "ARR at risk as a share of total customer ARR."
    type: number
    sql: SAFE_DIVIDE(${total_arr_at_risk}, NULLIF(${total_active_arr}, 0)) ;;
    value_format_name: percent_0
  }

  measure: renewal_arr_180d {
    label: "ARR Renewing in 180 Days"
    description: "Recurring revenue coming up for renewal in the next six months."
    type: sum
    sql: ${active_arr} ;;
    filters: [renews_within_180_days: "yes"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: average_utilization {
    label: "Avg Seat Utilization"
    description: "Mean active-to-licensed user ratio."
    type: average
    sql: ${utilization_pct} ;;
    value_format_name: percent_0
  }

  measure: average_risk_score {
    label: "Avg Account Risk Score"
    description: "Mean account risk score."
    type: average
    sql: ${risk_score} ;;
    value_format_name: decimal_0
  }

  measure: average_csat {
    label: "Avg CSAT"
    description: "Mean satisfaction score on a one-to-five scale."
    type: average
    sql: ${avg_csat_180d} ;;
    value_format_name: decimal_2
  }

  measure: total_tickets_90d {
    label: "Support Tickets (90d)"
    description: "Total Zendesk tickets raised in the last 90 days."
    type: sum
    sql: ${tickets_90d} ;;
    value_format_name: decimal_0
  }

  set: detail {
    fields: [
      account_name, qbr_rep_roster.rep_name, industry, active_arr,
      named_users, active_users_30d, utilization_pct, usage_trend_pct,
      tickets_90d, avg_csat_180d, next_renewal_date, risk_score, risk_band
    ]
  }
}
