# ---------------------------------------------------------------------------
# QBR refinements
#
# These refinements are included ONLY by saas_qbr.model.lkml. The original
# sfdc_demo model does not include this file, so every existing sfdc_demo
# Explore and dashboard continues to return byte-identical results.
#
# Two data-quality bugs are corrected here:
#
#   1. opportunity_line_item.closed_won_arr multiplied price by 100, so won ARR
#      read 100x higher than total_arr / pipeline_arr / forecast_arr, all of
#      which use plain ${price}.
#
#   2. salesforce_user.annual_arr_quota was hardcoded (20000*4 / 25000*4) and
#      then prorated by quota__start_month_num/12 - the month-of-year number,
#      not tenure. The result was a $25,000 quota sitting next to $35M of
#      bookings. The QBR model sources quota from aragosalooker.saas_qbr.rep_quota
#      instead, so these fields are hidden to stop anyone picking them up.
# ---------------------------------------------------------------------------

# The refined views reference product, opportunity, account and sales_rep, so
# the full sfdc_demo include set is pulled in to keep every reference resolvable.
include: "/sfdc_views/*.view.lkml"
include: "/sfdc_views/derived_tables/*.view.lkml"

view: +opportunity_line_item {
  measure: closed_won_arr {
    label: "Won ARR"
    description: "Sum of the ARR for opportunities that were won. Corrected: the base view multiplied price by 100."
    sql: ${price} ;;
  }
}

view: +salesforce_user {
  dimension: annual_arr_quota {
    hidden: yes
    description: "Deprecated in the QBR model. Use Quota & Attainment > ARR Quota, sourced from saas_qbr.rep_quota."
  }

  dimension: annual_services_quota {
    hidden: yes
    description: "Deprecated in the QBR model. Use Quota & Attainment > Services Quota, sourced from saas_qbr.rep_quota."
  }
}
