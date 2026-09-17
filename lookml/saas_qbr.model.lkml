# ===========================================================================
# saas_qbr - QBR Automation
#
# A purpose-built model for the quarterly business review workflow: quota and
# attainment, pipeline inspection, customer risk from product usage, and
# manager roll-ups.
#
# It reuses the saas_demo project's connection and views but does NOT modify
# the sfdc_demo model. Bug fixes live in qbr_views/qbr_refinements.view.lkml
# and are scoped to this model only.
# ===========================================================================

include: "/qbr_views/*.view.lkml"
include: "/qbr_dashboards/*.dashboard.lookml"

connection: "looker-private-demo"

label: "SaaS QBR Automation"

datagroup: qbr_daily {
  label: "QBR Daily Refresh"
  description: "Refreshes once a day. QBR source data lands on a daily cadence."
  sql_trigger: SELECT FORMAT_DATE('%F', CURRENT_DATE()) ;;
  max_cache_age: "12 hours"
}

persist_with: qbr_daily

# ---------------------------------------------------------------------------
# 1. Rep scorecard - quota vs. attainment. Also powers the manager roll-up,
#    because qbr_rep_roster carries the manager and team attributes.
# ---------------------------------------------------------------------------
explore: qbr_performance {
  view_name: qbr_rep_quota
  label: "QBR Rep Scorecard"
  description: "Quota, attainment, bookings, pipeline coverage and deal quality for every account executive, by quarter."
  group_label: "QBR"

  join: qbr_rep_roster {
    type: left_outer
    relationship: many_to_one
    sql_on: ${qbr_rep_quota.rep_id} = ${qbr_rep_roster.rep_id} ;;
  }

  join: qbr_rep_performance {
    type: left_outer
    relationship: one_to_one
    sql_on: ${qbr_rep_quota.rep_id} = ${qbr_rep_performance.rep_id}
        AND ${qbr_rep_quota.quarter_start_raw} = ${qbr_rep_performance.quarter_start_raw} ;;
  }
}

# ---------------------------------------------------------------------------
# 2. Deal inspection - "is this opportunity real?"
# ---------------------------------------------------------------------------
explore: qbr_pipeline_inspection {
  view_name: qbr_deal_quality
  label: "QBR Deal Inspection"
  description: "Opportunity-level risk scoring: close-date slips, stage age, activity silence, forecast mismatch, discounting and single-threading."
  group_label: "QBR"

  join: qbr_rep_roster {
    type: left_outer
    relationship: many_to_one
    sql_on: ${qbr_deal_quality.rep_id} = ${qbr_rep_roster.rep_id} ;;
  }

  join: qbr_account_risk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${qbr_deal_quality.account_id} = ${qbr_account_risk.account_id} ;;
  }
}

# ---------------------------------------------------------------------------
# 3. Customer risk from product usage
# ---------------------------------------------------------------------------
explore: qbr_customer_risk {
  view_name: qbr_account_risk
  label: "QBR Customer Risk"
  description: "Churn risk for every customer account, driven by seat utilization, usage trend, support load, CSAT and renewal timing."
  group_label: "QBR"

  join: qbr_rep_roster {
    type: left_outer
    relationship: many_to_one
    sql_on: ${qbr_account_risk.rep_id} = ${qbr_rep_roster.rep_id} ;;
  }
}

# ---------------------------------------------------------------------------
# 4. Manager / team roll-up
# ---------------------------------------------------------------------------
explore: qbr_team_rollup {
  view_name: qbr_sales_team
  label: "QBR Team Roll-Up"
  description: "Team-level plan versus actuals for every first-line sales manager, by quarter."
  group_label: "QBR"

  join: qbr_team_performance {
    type: left_outer
    relationship: one_to_one
    sql_on: ${qbr_sales_team.manager_id} = ${qbr_team_performance.manager_id}
        AND ${qbr_sales_team.quarter_start_raw} = ${qbr_team_performance.quarter_start_raw} ;;
  }
}
