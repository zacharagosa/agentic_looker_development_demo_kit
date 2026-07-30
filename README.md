# Looker CE Agentic Demo Kit: Master Overview & 5-Phase Playbook

Welcome to the **Looker Customer Engineering (CE) Agentic Demo Kit**. This kit equips CEs to deliver live, end-to-end demonstrations showing how **Looker** powered by **Jetski (Agentic AI)** accelerates BI development from zero to an interactive dashboard in under 10 minutes.

---

## 🏗️ Standard CE Demo Architecture

All Looker CEs use a single standardized architecture:
- **Cloudtop**: Linux workstation hosting your local workspace, scripts, and CLI tools (accessed via SSH).
- **Argolis Environment**: Your assigned Argolis GCP project (`go/argolis`) hosting BigQuery datasets and your Argolis Looker Core instance (`go/looker-argolis`).
- **Jetski Web**: Interactive browser UI (`go/jetski`) for conducting live agentic coding and dashboard generation in front of customers.

---

## 🗺️ The 5-Phase Linear Demo Journey

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: One-Time Environment Setup                                             │
│  Provision Cloudtop, Argolis Looker, and Jetski Web. SSH to Cloudtop and auth.   │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: Pre-Demo Readiness Check (5 Mins Before Meeting)                       │
│  Run python3 scripts/ce_preflight_check.py to verify Argolis tokens & connection │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: Live Customer Discovery & Data Source Selection (Mins 0-2 of Call)     │
│  Ask 3 discovery questions -> Select Option A (Custom), B (Looker Demo), or C (CSV)│
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: Live Agentic Build & CE Narrative via Jetski Web (Mins 2-5 of Call)    │
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

## 📂 Kit Directory & Tools Index

```
looker-ce-demo-kit/
├── README.md                          # Master overview and 5-phase journey
├── ce_environment_setup.md            # Phase 1: One-Time Setup Guide (Provisioning, SSH, Cloudtop, Argolis)
├── ce_demo_playbook.md                # Full presentation script, talking points, & narrative guide
├── scripts/
│   ├── ce_preflight_check.py          # Phase 2: Automated environment readiness check script
│   └── generate_demo_data.py          # Phase 4: Dynamic multi-table schema & synthetic data generator
├── skills/
│   └── generating-demo-data-for-looker/
│       └── SKILL.md                   # Phase 4: Custom Jetski skill for data discovery & BQ loading
└── templates/
    ├── custom_live_demo.md            # Phase 3: Data source selection & interactive prompt template
    ├── telecom_demo.md                # Phase 3: Telecom & 5G network performance analytics scenario
    ├── ecommerce_demo.md              # Phase 3: Pre-packaged E-Commerce prompt template
    └── saas_demo.md                   # Phase 3: Pre-packaged SaaS ARR prompt template
```

---

## ⚡ Quick Reference: How to Execute Each Phase

### Phase 1: One-Time Setup & Provisioning
Provision platforms via [go/cloudtop](http://go/cloudtop), [go/argolis](http://go/argolis), and [go/jetski](http://go/jetski). SSH into Cloudtop and authenticate:
```bash
ssh <your-ldap>@<your-cloudtop-hostname>.c.googlers.com
gcloud auth login   # Use Argolis User Account (NOT @google.com)
looker-cli session login --oauth
```

### Phase 2: Pre-Demo Readiness Check (5 mins before call)
Run the health check script on Cloudtop:
```bash
python3 scripts/ce_preflight_check.py --connection-name {your_looker_bq_connection}
```

### Phase 3: Live Customer Discovery (Mins 0–2 of call)
Ask the 3 discovery questions and choose your scenario prompt (e.g. `templates/telecom_demo.md` or `templates/custom_live_demo.md`).

### Phase 4: Live Agentic Build & Narrative via Jetski Web (Mins 2–5 of call)
Send prompt to **Jetski Web**. Narrate Looker's semantic layer governance while Jetski builds.

### Phase 5: Live Dashboard Demo & Iteration (Mins 5–10 of call)
Open the generated Looker URL in your browser, ask the customer for a live modification, and prompt **Jetski Web** to update the LookML/Dashboard in real time.
