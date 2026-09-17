-- =============================================================================
-- CloudScale Enterprise — Automated SaaS Executive QBR Studio
-- BigQuery Schema & Derived Analytics Views Setup Script
-- =============================================================================
-- Run this script in BigQuery to create the `saas_qbr` dataset, core tables,
-- and analytical views backing the Looker `saas_qbr` semantic model.

CREATE SCHEMA IF NOT EXISTS `saas_qbr` OPTIONS(location="US");

-- 1. Narrative Cache Table (for Gemini 3.8 Flash Grounded QBR Prose)
CREATE TABLE IF NOT EXISTS `saas_qbr.qbr_narrative_cache` (
  subject_id STRING,
  subject_type STRING,
  fiscal_quarter STRING,
  section STRING,
  narrative STRING,
  model_name STRING,
  generated_at TIMESTAMP
);

-- 2. Deal Quality Score View (identifies slip counts, stage stalling, and zombie deals)
-- Note: Adjust source project/dataset (`looker-private-demo.salesforce.*`) to match your CRM tables.
CREATE OR REPLACE VIEW `saas_qbr.deal_quality_score` AS
WITH slip_history AS (
  SELECT
    OPPORTUNITY_ID,
    COUNT(DISTINCT CLOSE_DATE) - 1 AS slip_count
  FROM `looker-private-demo.salesforce.opportunity_history`
  GROUP BY OPPORTUNITY_ID
)
SELECT
  o.ID AS opportunity_id,
  o.NAME AS opportunity_name,
  o.OWNER_ID AS rep_id,
  o.ACCOUNT_ID AS account_id,
  o.STAGE_NAME AS stage_name,
  o.FORECAST_CATEGORY AS forecast_category,
  DATE(o.CLOSE_DATE) AS close_date,
  o.IS_CLOSED AS is_closed,
  o.IS_WON AS is_won,
  COALESCE(s.slip_count, 0) AS slip_count,
  DATE_DIFF(CURRENT_DATE(), DATE(o.LAST_STAGE_CHANGE_DATE), DAY) AS days_in_current_stage,
  DATE_DIFF(CURRENT_DATE(), DATE(o.LAST_ACTIVITY_DATE), DAY) AS days_since_last_activity,
  CASE
    WHEN COALESCE(s.slip_count, 0) >= 4 OR DATE_DIFF(CURRENT_DATE(), DATE(o.LAST_STAGE_CHANGE_DATE), DAY) > 90 THEN 'High Risk'
    WHEN COALESCE(s.slip_count, 0) >= 2 OR DATE_DIFF(CURRENT_DATE(), DATE(o.LAST_STAGE_CHANGE_DATE), DAY) > 56 THEN 'Medium Risk'
    ELSE 'Healthy'
  END AS risk_band
FROM `looker-private-demo.salesforce.opportunity` o
LEFT JOIN slip_history s ON o.ID = s.OPPORTUNITY_ID;
