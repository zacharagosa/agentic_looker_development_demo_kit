# Looker CE Master Playbook: End-to-End Live Demo Guide

This playbook provides a **linear, 5-phase journey** for Customer Engineers (CEs) to set up their environment, verify readiness before a meeting, conduct customer discovery, run an automated live agentic build, and iterate on Looker dashboards live in front of a customer.

---

## 🗺️ The 5-Phase End-to-End Journey Overview

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: One-Time Environment Setup                                             │
│  Configure Cloudtop, gcloud (Argolis User), bq, and looker-cli                   │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: Pre-Demo Readiness Check (5 Mins Before Meeting)                       │
│  Run automated health check script on Cloudtop to verify tokens & connection      │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: Live Customer Discovery & Data Source Selection (Mins 0-2 of Call)     │
│  Ask customer 3 questions -> Select Option A (Custom), B (Looker Demo), or C (CSV)│
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: Live Agentic Build & Narrative via Jetski Web (Mins 2-5 of Call)       │
│  Prompt Jetski Web -> Agent builds BigQuery tables, LookML, and Looker Dashboard │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: Live Dashboard Demo & Real-Time Customer Iteration (Mins 5-10)          │
│  Open dashboard URL -> Invite customer challenges -> Prompt Jetski Web for edits │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: One-Time Environment Setup

### Goal
Configure your **Cloudtop** workstation with required CLI tools and authenticate using your **Argolis user account**.

### CE Checklist & Actions
1. **Verify CLI Tools**: Ensure `gcloud`, `bq`, and `looker-cli` are in your Cloudtop `PATH`.
2. **Authenticate `gcloud` with Argolis User**:
   ```bash
   # Use your Argolis user identity (NOT @google.com Corp account)
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project YOUR_ARGOLIS_GCP_PROJECT_ID
   ```
3. **Authenticate `looker-cli`**:
   ```bash
   looker-cli session login --oauth
   ```

### Supporting Detailed Guide
- Refer to [`ce_environment_setup.md`](file:///usr/local/google/home/aragosa/.gemini/jetski/scratch/looker-ce-demo-kit/ce_environment_setup.md) for full step-by-step setup details.

---

## PHASE 2: Pre-Demo Readiness Check (5 Minutes Before Call)

### Goal
Perform a 5-second health check to verify active tokens, Argolis database connections, and permissions before jumping on the call.

### CE Actions
Run the automated pre-flight health check script on your Cloudtop:
```bash
python3 /usr/local/google/home/aragosa/.gemini/jetski/scratch/looker-ce-demo-kit/scripts/ce_preflight_check.py --connection-name {your_looker_bq_connection}
```

### What the Tool Checks
- [x] **`gcloud`**: Active Argolis account login and default GCP project.
- [x] **`bq`**: BigQuery API accessibility in Argolis project.
- [x] **`looker-cli`**: Session validity (`user me`) and Looker DB Connection mapping.

---

## PHASE 3: Live Customer Discovery & Data Source Selection (Mins 0–2)

### Goal
Align with the customer on their industry domain and select the appropriate data source mode.

### CE Actions
Ask the customer these **3 Discovery Questions**:
1. *"What is your primary business domain?"* (e.g. Retail, SaaS, Healthcare, Logistics, Gaming)
2. *"What are 2–3 key entities you track?"* (e.g. Orders, Users, Products OR Accounts, Subscriptions)
3. *"What top 3 KPIs do your executives care about most?"* (e.g. Revenue, Churn, AOV, Readmission Rate)

### Choose Your Data Source Mode

| Mode | Use Case | Tool / Directive |
| :--- | :--- | :--- |
| **Option A: Dynamic Agent-Generated Custom Schema** | Customer requests a custom/niche domain (e.g., Logistics, Gaming, Real Estate) | Agent designs schema JSON & runs `generate_demo_data.py --schema-json` |
| **Option B: Standard `looker-private-demo` BQ Project** | Fast default demo using Google's curated BQ demo datasets (`ecom`, `thelook`, `saas`, `retail`) | Agent explores `looker-private-demo:{dataset}` |
| **Option C: Customer Sample CSV Files** | Customer brought sample CSV files to the meeting | Agent loads CSVs into BigQuery |

### Supporting Tools
- [`templates/custom_live_demo.md`](file:///usr/local/google/home/aragosa/.gemini/jetski/scratch/looker-ce-demo-kit/templates/custom_live_demo.md): Prompt template builder.

---

## PHASE 4: Live Agentic Build & CE Presentation Narrative via Jetski Web (Mins 2–5)

### Goal
Trigger **Jetski Web** in your browser to build the full BI solution while narrating Looker's value proposition to the customer.

### CE Actions
Paste your formatted prompt into the **Jetski Web** chat interface in your browser.

### CE Narrative Script (What to Say While Jetski Operates)

- **Minute 2 (Data Ingestion)**:
  > *"Notice how Jetski is connecting to BigQuery and inspecting our table structures. Whether you use pre-existing BigQuery datasets or ingest customer CSVs, Jetski auto-detects column types, foreign key relationships, and timestamps."*

- **Minute 3 (LookML Modeling & Governance)**:
  > *"Unlike raw LLM-to-SQL tools that generate un-governed text queries, Looker relies on LookML—a centralized semantic layer. Jetski is creating LookML View files with primary keys, dimensions, and measures, then constructing an Explore with explicit join relationships."*

- **Minute 4 (Zero-Error Compiler Validation)**:
  > *"Jetski adheres to a strict Zero-Error Policy. Before publishing anything, it calls Looker's compiler (`validate_project`) and executes inline test queries to guarantee zero SQL syntax or runtime errors."*

### Supporting Skills Executed by Agent
- [`generating-demo-data-for-looker`](file:///usr/local/google/home/aragosa/.gemini/jetski/scratch/looker-ce-demo-kit/skills/generating-demo-data-for-looker/SKILL.md)
- [`creating-lookml-model`](file:///usr/local/google/home/aragosa/.gemini/config/skills/creating-lookml-model/SKILL.md)
- [`creating-looker-dashboard`](file:///usr/local/google/home/aragosa/.gemini/config/skills/creating-looker-dashboard/SKILL.md)

---

## PHASE 5: Live Dashboard Demo & Real-Time Customer Iteration (Mins 5–10)

### Goal
Show the generated Looker UDD dashboard live in your browser and demonstrate real-time agile modifications based on customer feedback.

### CE Actions
1. Open the interactive Looker dashboard URL returned by Jetski Web in your browser.
2. Invite customer challenge:
   > *"What metric, filter, or chart modification would you like to see added right now?"*
3. Prompt Jetski Web with their request in plain English:
   > *"Jetski, add a gross margin % measure, group top product categories in a stacked bar chart, and add an order status filter to the dashboard."*
4. Refresh the Looker dashboard live to show the updated visualization.

---

## Summary Matrix: Phases, Tools & Actions

| Phase | Phase Name | Main CE Action | Primary Tool / Script | Output / Milestone |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | One-Time Setup | Authenticate Argolis user on Cloudtop | `ce_environment_setup.md`, `gcloud auth login` | Environment configured |
| **Phase 2** | Pre-Demo Check | Run 5-sec readiness test | `python3 scripts/ce_preflight_check.py` | Green `[PASS]` status |
| **Phase 3** | Customer Discovery | Ask 3 questions & pick Option A/B/C | `templates/custom_live_demo.md` | Tailored prompt ready |
| **Phase 4** | Live Agentic Build | Send prompt in Jetski Web & narrate | Jetski Web + Looker skills | Validated LookML & Dashboard URL |
| **Phase 5** | Live Iteration | Open Looker URL & make live edits | Looker Core UI + Jetski Web | Live interactive customer wow-factor |
