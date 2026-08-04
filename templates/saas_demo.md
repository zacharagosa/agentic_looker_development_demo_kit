# Demo Scenario Template: SaaS ARR & Subscriptions (using `looker-private-demo`)

## Business Context
Demonstrate how Looker's agentic model building handles complex business logic like Monthly Recurring Revenue (MRR), Churn Rates, Subscription Expansion, and Account Tiers using `looker-private-demo`.

## Pre-flight Setup
- **BigQuery Data Source**: Project `looker-private-demo`, Dataset `saas` (or `saas_events`)
- **Looker Connection**: `{your_looker_connection_name}`
- **Looker Project**: `agentic_saas_demo`
- **Pre-Call Preparation**: Pre-fill this template outline with baseline assumptions ahead of the call. Walk through it with the customer at the start of the call to confirm the approach and make any adjustments on the fly.

## Prompt to Copy-Paste into Jetski during Live Demo
> "Jetski, we are demoing Looker agentic LookML for a SaaS B2B customer using the `looker-private-demo` BigQuery project dataset `saas`.
> 
> Please explore `looker-private-demo:saas`, build LookML view files, model file with joins, map the connection, validate LookML, and create an Executive SaaS Dashboard featuring Total ARR, Active Subscriptions, Net MRR Change, and Churn Rate by Plan Tier."

## Key Metrics to Showcase Live
1. **Total Annual Recurring Revenue (ARR)** (`sum(mrr_amount) * 12`)
2. **Active Accounts & Subscriptions**
3. **Net MRR Expansion & Churn**
4. **Subscription Distribution by Tier** (Starter vs Professional vs Enterprise)
