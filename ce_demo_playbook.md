# Looker CE Master Playbook: End-to-End Live Demo Guide

This playbook provides a **linear, 5-phase journey** for Customer Engineers (CEs) to set up their environment, conduct rapid customer alignment, **kick off the agent early to eliminate dead air**, present the "Under the Hood" agentic architecture while the agent builds, and iterate on Looker dashboards live in front of a customer.

---

## 🗺️ Optimized Customer Meeting Flow & Timeline

To eliminate dead air while Jetski executes, the CE kicks off the agent prompt **immediately after customer alignment**, then walks through a 3-slide "Under the Hood Architecture" presentation while Jetski operates seamlessly in the background.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: Pre-Demo Readiness & Prompt Outline (Before Call)                      │
│  Run preflight check -> Pre-fill prompt template outline & planned approach      │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: Customer Alignment & Prompt Confirmation (Start of Call)               │
│  Walk through pre-filled template w/ customer -> Adjust prompt on the fly        │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: Kick Off Agent & "Under the Hood" Tools Walkthrough (During Execution) │
│  ⚡ KICK OFF JETSKI WEB IMMEDIATELY AFTER ALIGNMENT ⚡                           │
│  While Jetski builds in background, present 3 key architecture tools:           │
│  1. Looker Semantic Layer (LookML) vs Raw LLM SQL                                │
│  2. Looker Skills & Model Context Protocol (MCP Server)                          │
│  3. Looker CLI (`looker-cli`) & Zero-Error Compiler Validation                   │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: Reveal Generated Looker Dashboard (Dashboard Reveal)                   │
│  Open generated UDD dashboard link live in Argolis Looker UI                     │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: Live Dashboard Demo & Real-Time Customer Iteration (Live Iteration)    │
│  Invite customer challenges -> Prompt Jetski Web for live real-time edits        │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: Pre-Demo Readiness & Prompt Outline (Before Call)

### Goal
Perform a health check on your Cloudtop to verify active tokens and Argolis database connections, and **create an initial outline of your prompt template ahead of the call**. Coming prepared with a general template filled out and a planned approach ensures a smooth, professional discussion.

### CE Actions
1. **Run Pre-Flight Check**:
```bash
python3 scripts/ce_preflight_check.py --connection-name {your_looker_bq_connection}
```
2. **Draft & Outline Prompt Template Ahead of Call**:
   - Choose a starting template from [`templates/`](templates/) (e.g., [`telecom_demo.md`](templates/telecom_demo.md), [`custom_live_demo.md`](templates/custom_live_demo.md), or [`ecommerce_demo.md`](templates/ecommerce_demo.md)).
   - Pre-fill the template with your baseline approach, anticipated tables/metrics, and use-case assumptions so you come to the meeting prepared.

---

## PHASE 2: Customer Alignment & Prompt Confirmation (Start of Call)

### Goal
Walk through your pre-filled prompt template with the customer at the start of the call to confirm the approach and make any on-the-fly adjustments before execution.

### CE Actions
1. **Share & Confirm the Template**: Show the customer the general prompt outline you prepared ahead of the call.
2. **Ask Discovery & Alignment Questions**:
   - *"We prepared this baseline outline for [Industry/Domain] focusing on [Entities] and [KPIs]. Does this approach and structure align with what your team wants to see today?"*
   - *"Are there any specific metrics or dimensions you'd like us to adjust or add to this prompt before we kick it off?"*
3. **Make Live Adjustments**: Modify any fields, KPIs, or wording in the template on the fly based on customer feedback before submitting to Jetski.

---

## PHASE 3: Kick Off Agent & "Under the Hood" Tools Walkthrough (During Agent Execution)

### Goal
**Kick off Jetski Web immediately after customer alignment**, then present a brief, high-value 3-part tools walkthrough while Jetski builds the BigQuery tables, LookML, and dashboard in the background.

### CE Action: Kick Off Agent
Paste your prompt into **Jetski Web** and click Send. Once the agent starts executing, switch your shared screen to your slides/architecture diagram!

---

### 🎙️ CE Presentation Narrative & Slide Script (During Agent Execution)

#### Slide 1: The Foundation — Looker Semantic Layer (LookML) vs Raw SQL
> *"While Jetski is building our solution live in BigQuery and Looker, let's talk about why agentic AI works so well with Looker compared to other BI platforms.*
> 
> *Raw LLM-to-SQL text generators attempt to query database tables directly. The problem? Every user gets different SQL logic, hallucinated join paths, and conflicting definitions for key metrics like 'Revenue' or 'Churn'.*
> 
> *Looker solves this with **LookML**—a centralized, governed semantic layer. The agent doesn't write raw, un-governed SQL; it codes structured LookML views and models. Once defined, every business user gets single-source-of-truth accuracy across the enterprise."*

---

#### Slide 2: The Agentic Core — Looker Skills & Model Context Protocol (MCP Server)
> *"How does the agent know how to write production-grade LookML? It uses two key Google technologies:*
> 
> 1. ***Looker Skills***: Pre-packaged expert workflows that instruct the agent on modeling best practices, primary key declarations, explicit join relationships, and Liquid performance optimizations.
> 2. ***Looker MCP Server (Model Context Protocol)***: An open protocol that gives the agent standardized tool access to discover database schemas, inspect table columns, manage project directories, and programmatically invoke Looker APIs."*

---

#### Slide 3: Quality Assurance — Looker CLI (`looker-cli`) & Zero-Error Compiler Validation
> *"How do we ensure the agent doesn't generate broken code? Let's look at **Zero-Error Compiler Validation**.*
> 
> *Every time Jetski generates or edits LookML code, it executes a two-step automated quality-assurance loop:*
> 
> 1. ***Step 1: Automated LookML Compiler Validation (`validate_project`)***: Jetski programmatically calls Looker's official compiler API using `looker-cli api project validate_project`. If the compiler reports ANY syntax error, missing join, or broken field reference, **Jetski intercepts the error log, diagnoses the issue, and self-heals by rewriting the LookML file automatically** until Looker returns 0 errors.
> 2. ***Step 2: Inline SQL Runtime Query Verification***: Once compiled cleanly, Jetski executes a real inline test query against Google BigQuery (`looker-cli query runquery`) to prove that the underlying SQL generated by LookML executes successfully without database runtime errors.*

##### Traditional LLM-to-SQL vs. Looker + Jetski Zero-Error Validation:

| Traditional LLM-to-SQL (e.g., ChatGPT / Copilot) | Looker + Jetski (Zero-Error Compiler Validation) |
| :--- | :--- |
| Generates un-verified text strings | Generates structured, compiler-validated LookML |
| User must manually copy-paste to discover syntax errors | Agent programmatically compiles code & self-heals its own bugs |
| Frequent SQL hallucinations on schema changes | Governed semantic layer guaranteed to run valid SQL |

> 🎙️ **CE Soundbite to Use in Meetings**:  
> *"Most AI tools just spit out text and cross their fingers. Notice how Jetski acts like a real software engineer—it compiles its LookML against Looker's compiler and runs a live BigQuery test query. Under our Zero-Error Policy, it never presents a dashboard to you unless it compiles cleanly and runs without errors."*

---

## PHASE 4: Reveal Generated Looker Dashboard (Dashboard Reveal)

### Goal
Switch back to your browser window and present the completed, fully modeled Looker dashboard URL generated by Jetski Web. (Ensure all LookML changes and project branches are automatically deployed to production via accepts 1 arg(s), received 0 so viewers do not need Dev mode).

### CE Actions
1. Open the Looker UDD URL returned in Jetski Web's final response message.
2. Point out key elements:
   - Executive Summary KPIs (Total Revenue, ARPU, Active Subscribers/Orders).
   - Governed dimensions & drill-down capabilities.
   - Clean visualization tiles (trend charts, stacked bar charts).

---

## PHASE 5: Live Dashboard Demo & Real-Time Customer Iteration (Live Iteration)

### Goal
Demonstrate real-time agile modifications live in front of the customer based on their direct feedback.

### CE Actions
1. Turn to the customer and ask:
   > *"Now that we've built a baseline solution, what additional metric, drill path, or visual calculation would you like to see added?"*
2. Feed their request into **Jetski Web** in plain English:
   > *"Jetski, add a gross margin % measure to the view, group top categories in a stacked bar chart, and add a status filter to the dashboard."*
3. Refresh the Looker dashboard live to reveal the updated visualization!

---

## Summary Matrix: Phases, Tools & Actions

| Phase | Stage | Main CE Action | Primary Tool / Script | Key Output / Milestone |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | Pre-Call | Run readiness check & pre-fill prompt outline | `python3 scripts/ce_preflight_check.py` + `templates/` | Green `[PASS]` & prompt outline ready |
| **Phase 2** | Start of Call | Walk through & confirm pre-filled prompt | Pre-filled prompt template | Aligned prompt adjusted on the fly |
| **Phase 3** | During Execution | **Kick off Jetski Web** & walk through 3 slides | Slide Deck (LookML, MCP, `looker-cli`) | Agent builds in background without dead air |
| **Phase 4** | Dashboard Reveal | Open generated Looker UDD URL | Argolis Looker Core UI | Reveal live interactive dashboard |
| **Phase 5** | Live Iteration | Invite customer edits & prompt agent | Jetski Web + Looker Core UI | Real-time agile modification wow-factor |
