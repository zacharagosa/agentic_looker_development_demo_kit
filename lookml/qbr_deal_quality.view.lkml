view: qbr_deal_quality {
  label: "Deal Inspection"
  sql_table_name: `aragosalooker.saas_qbr.deal_quality_score` ;;

  dimension: opportunity_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.opportunity_id ;;
  }

  dimension: account_id { hidden: yes  type: string  sql: ${TABLE}.account_id ;; }
  dimension: rep_id     { hidden: yes  type: string  sql: ${TABLE}.rep_id ;; }

  dimension: opportunity_name {
    label: "Opportunity"
    description: "Account name plus deal type."
    type: string
    sql: ${TABLE}.opportunity_name ;;
    link: {
      label: "Inspect this deal"
      url: "/dashboards/saas_qbr::is_this_deal_real?Opportunity={{ value | url_encode }}"
    }
  }

  dimension: opportunity_type {
    label: "Deal Type"
    description: "New Business, Renewal, Upsell and so on."
    type: string
    sql: ${TABLE}.opportunity_type ;;
  }

  dimension: stage_name {
    label: "Stage"
    description: "Normalised sales stage."
    type: string
    sql: ${TABLE}.stage_name ;;
  }

  dimension: forecast_category {
    label: "Forecast Category"
    description: "Commit (Forecast), Upside, Pipeline or Omitted."
    type: string
    sql: ${TABLE}.forecast_category ;;
  }

  dimension: probability {
    label: "Probability"
    description: "Salesforce win probability recorded on the deal."
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.probability / 100 ;;
  }

  dimension: amount {
    label: "Deal Amount"
    description: "Opportunity amount as recorded in Salesforce."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.amount ;;
  }

  dimension: arr_amount {
    label: "Deal ARR"
    description: "Recurring revenue on the deal's line items."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.arr_amount ;;
  }

  dimension: nrr_amount {
    label: "Deal Services Revenue"
    description: "Non-recurring revenue on the deal's line items."
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.nrr_amount ;;
  }

  dimension_group: close {
    label: "Close"
    description: "Current expected or actual close date."
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.close_date ;;
  }

  dimension_group: created {
    label: "Created"
    description: "Date the opportunity was created."
    type: time
    timeframes: [raw, date, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.created_date ;;
  }

  dimension: original_close_date {
    label: "Original Close Date"
    description: "The first close date ever recorded on this deal."
    type: date
    convert_tz: no
    datatype: date
    sql: ${TABLE}.original_close_date ;;
  }

  dimension: is_closed {
    label: "Is Closed"
    description: "Whether the deal has reached Closed Won or Closed Lost."
    type: yesno
    sql: ${TABLE}.is_closed ;;
  }

  dimension: is_self_sourced {
    label: "Is Self Sourced"
    description: "Whether the owning rep also created the opportunity."
    type: yesno
    sql: ${TABLE}.is_self_sourced ;;
  }

  # ------------------------------------------------------------ risk signals

  dimension: slip_count {
    label: "Close-Date Slips"
    description: "How many times the close date has been pushed out. Four or more is a serious warning."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.slip_count ;;
  }

  dimension: slip_band {
    label: "Slip Band"
    description: "Bucketed close-date slips."
    type: string
    sql: CASE
           WHEN COALESCE(${TABLE}.slip_count, 0) = 0 THEN "Never slipped"
           WHEN ${TABLE}.slip_count <= 1 THEN "1 slip"
           WHEN ${TABLE}.slip_count <= 3 THEN "2-3 slips"
           WHEN ${TABLE}.slip_count <= 6 THEN "4-6 slips"
           ELSE "7+ slips"
         END ;;
    order_by_field: slip_band_sort
  }

  dimension: slip_band_sort {
    hidden: yes
    type: number
    sql: CASE
           WHEN COALESCE(${TABLE}.slip_count, 0) = 0 THEN 0
           WHEN ${TABLE}.slip_count <= 1 THEN 1
           WHEN ${TABLE}.slip_count <= 3 THEN 2
           WHEN ${TABLE}.slip_count <= 6 THEN 3
           ELSE 4
         END ;;
  }

  dimension: total_slip_days {
    label: "Total Slip Days"
    description: "Days between the original close date and the current one."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.total_slip_days ;;
  }

  dimension: days_in_current_stage {
    label: "Days in Stage"
    description: "Days the deal has sat in its present stage. Over 56 days is stale."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.days_in_current_stage ;;
  }

  dimension: is_stale {
    label: "Is Stale"
    description: "Deal has been in the same stage for more than 56 days."
    type: yesno
    sql: COALESCE(${TABLE}.days_in_current_stage, 0) > 56 ;;
  }

  dimension: deal_age_days {
    label: "Deal Age (Days)"
    description: "Days since the opportunity was created."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.deal_age_days ;;
  }

  dimension: days_since_last_activity {
    label: "Days Since Last Activity"
    description: "Days since anyone logged an activity against the account."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.days_since_last_activity ;;
  }

  dimension: activities_90d {
    label: "Activities (90d)"
    description: "Sales activities logged against the account in the last 90 days."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.activities_90d ;;
  }

  dimension: contact_count {
    label: "Contacts on Account"
    description: "Known contacts. A single contact means the deal is single-threaded."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.contact_count ;;
  }

  dimension: is_single_threaded {
    label: "Is Single Threaded"
    description: "Only one known contact at the account."
    type: yesno
    sql: COALESCE(${TABLE}.contact_count, 0) <= 1 ;;
  }

  dimension: discount_depth {
    label: "Discount Depth"
    description: "Percent off list price across the deal's line items."
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.discount_depth ;;
  }

  dimension: line_item_count {
    label: "Products on Deal"
    description: "Number of line items attached to the opportunity."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.line_item_count ;;
  }

  # ------------------------------------------------------------ scoring

  dimension: risk_score {
    label: "Deal Risk Score"
    description: "Zero to 100. Combines close-date slips, stage age, activity silence, forecast mismatch, discounting and single-threading."
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.risk_score ;;
  }

  dimension: risk_band {
    label: "Deal Risk Band"
    description: "Healthy under 40, Medium Risk 40 to 64, High Risk 65 and above."
    type: string
    sql: ${TABLE}.risk_band ;;
    order_by_field: risk_band_sort
    html:
      {% if value == 'High Risk' %}<span style="color:#B3261E;font-weight:600;">{{ value }}</span>
      {% elsif value == 'Medium Risk' %}<span style="color:#B26A00;font-weight:600;">{{ value }}</span>
      {% else %}<span style="color:#146C2E;font-weight:600;">{{ value }}</span>{% endif %} ;;
  }

  dimension: risk_band_sort {
    hidden: yes
    type: number
    sql: CASE ${TABLE}.risk_band WHEN "High Risk" THEN 1 WHEN "Medium Risk" THEN 2 ELSE 3 END ;;
  }

  dimension: score_slip           { group_label: "Risk Drivers" label: "Slip Points"            description: "Risk points from close-date slips (max 25)."          type: number value_format_name: decimal_1 sql: ${TABLE}.score_slip ;; }
  dimension: score_stage_age      { group_label: "Risk Drivers" label: "Stage Age Points"       description: "Risk points from time stuck in stage (max 25)."       type: number value_format_name: decimal_1 sql: ${TABLE}.score_stage_age ;; }
  dimension: score_activity       { group_label: "Risk Drivers" label: "Activity Silence Points" description: "Risk points from lack of recent activity (max 20)." type: number value_format_name: decimal_1 sql: ${TABLE}.score_activity ;; }
  dimension: score_commit_mismatch{ group_label: "Risk Drivers" label: "Forecast Mismatch Points" description: "Risk points when a commit deal looks stalled (max 15)." type: number value_format_name: decimal_1 sql: ${TABLE}.score_commit_mismatch ;; }
  dimension: score_discount       { group_label: "Risk Drivers" label: "Discount Points"        description: "Risk points from deep discounting (max 10)."          type: number value_format_name: decimal_1 sql: ${TABLE}.score_discount ;; }
  dimension: score_single_threaded{ group_label: "Risk Drivers" label: "Single Thread Points"   description: "Risk points when only one contact is known (max 5)."  type: number value_format_name: decimal_1 sql: ${TABLE}.score_single_threaded ;; }

  dimension: is_zombie {
    label: "Is Zombie Deal"
    description: "Slipped four or more times AND stuck in stage for over 90 days. Almost certainly not real."
    type: yesno
    sql: ${TABLE}.is_zombie ;;
  }

  dimension: is_questionable_commit {
    label: "Is Questionable Commit"
    description: "Sitting in the commit forecast despite being stalled in stage for more than 56 days."
    type: yesno
    sql: ${TABLE}.is_questionable_commit ;;
  }

  # ------------------------------------------------------------ measures

  measure: deal_count {
    label: "Deals"
    description: "Number of opportunities."
    type: count
    drill_fields: [detail*]
  }

  measure: open_deal_count {
    label: "Open Deals"
    description: "Opportunities not yet closed."
    type: count
    filters: [is_closed: "no"]
    drill_fields: [detail*]
  }

  measure: total_arr {
    label: "Pipeline ARR"
    description: "Recurring revenue across the selected opportunities."
    type: sum
    sql: ${arr_amount} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: open_arr {
    label: "Open Pipeline ARR"
    description: "Recurring revenue on opportunities that are still open."
    type: sum
    sql: ${arr_amount} ;;
    filters: [is_closed: "no"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
  }

  measure: high_risk_arr {
    label: "High Risk ARR"
    description: "Open recurring revenue scored High Risk."
    type: sum
    sql: ${arr_amount} ;;
    filters: [is_closed: "no", risk_band: "High Risk"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: zombie_arr {
    label: "Zombie ARR"
    description: "Open recurring revenue on zombie deals."
    type: sum
    sql: ${arr_amount} ;;
    filters: [is_closed: "no", is_zombie: "yes"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: questionable_commit_arr {
    label: "Questionable Commit ARR"
    description: "Commit-category revenue on deals that are stalled."
    type: sum
    sql: ${arr_amount} ;;
    filters: [is_closed: "no", is_questionable_commit: "yes"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$0"
    drill_fields: [detail*]
  }

  measure: zombie_deal_count {
    label: "Zombie Deals"
    description: "Open opportunities that have slipped repeatedly and gone quiet."
    type: count
    filters: [is_closed: "no", is_zombie: "yes"]
    drill_fields: [detail*]
  }

  measure: stale_deal_count {
    label: "Stale Deals"
    description: "Open opportunities untouched in their current stage for more than 56 days."
    type: count
    filters: [is_closed: "no", is_stale: "yes"]
    drill_fields: [detail*]
  }

  measure: average_risk_score {
    label: "Avg Deal Risk Score"
    description: "Mean risk score across the selected opportunities."
    type: average
    sql: ${risk_score} ;;
    value_format_name: decimal_0
  }

  measure: average_slip_count {
    label: "Avg Close-Date Slips"
    description: "Mean number of close-date pushes."
    type: average
    sql: ${slip_count} ;;
    value_format_name: decimal_1
  }

  measure: average_days_in_stage {
    label: "Avg Days in Stage"
    description: "Mean days the selected deals have sat in their present stage."
    type: average
    sql: ${days_in_current_stage} ;;
    value_format: "0\" days\""
  }

  measure: average_discount {
    label: "Avg Discount"
    description: "Mean discount off list price."
    type: average
    sql: ${discount_depth} ;;
    value_format_name: percent_1
  }

  measure: percent_high_risk_arr {
    label: "% Pipeline at High Risk"
    description: "High Risk ARR as a share of all open pipeline ARR."
    type: number
    sql: SAFE_DIVIDE(${high_risk_arr}, NULLIF(${open_arr}, 0)) ;;
    value_format_name: percent_0
  }

  set: detail {
    fields: [
      opportunity_name, qbr_rep_roster.rep_name, stage_name, forecast_category,
      close_date, arr_amount, slip_count, days_in_current_stage,
      days_since_last_activity, contact_count, risk_score, risk_band
    ]
  }
}
