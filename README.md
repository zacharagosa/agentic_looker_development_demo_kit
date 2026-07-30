# Looker CE Agentic Demo Kit: Master Overview & 5-Phase Playbook

Welcome to the **Looker Customer Engineering Agentic Demo Kit**. This kit equips CEs to deliver live, end-to-end demonstrations showing how **Looker** powered by Agentic AI accelerates BI development from zero to an interactive dashboard in under 10 minutes.

## 🗺️ Looker Demo Steps

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: Pre-Demo Readiness & Prompt Outline (Before Call)                      │
│  Run preflight check -> Pre-fill prompt template outline & planned approach      │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: Customer Alignment & Prompt Confirmation (Min 0-1 of Call)             │
│  Walk through pre-filled template w/ customer -> Adjust prompt on the fly        │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: Kick Off Agent & "Under the Hood" Tools Walkthrough (Mins 1-4 of Call) │
│  ⚡ KICK OFF JETSKI WEB AT MINUTE 1 ⚡                                            │
│  While Jetski builds in background, present 3 key architecture tools:           │
│  1. Looker Semantic Layer (LookML) vs Raw LLM SQL                                │
│  2. Looker Skills & Model Context Protocol (MCP Server)                          │
│  3. Looker CLI (`looker-cli`) & Zero-Error Compiler Validation                   │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: Reveal Generated Looker Dashboard (Min 4 of Call)                      │
│  Open generated UDD dashboard link live in Argolis Looker UI                     │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: Live Dashboard Demo & Real-Time Customer Iteration (Mins 4-10 of Call) │
│  Invite customer challenges -> Prompt Jetski Web for live real-time edits        │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📂 Kit Directory & Tools Index

```
looker-ce-demo-kit/
├── README.md                          # Master overview, Zero-Error definition, & 5-phase journey
├── ce_environment_setup.md            # Phase 1: One-Time Setup Guide (Provisioning, SSH, Cloudtop, Argolis)
├── ce_demo_playbook.md                # Full presentation script, 3-slide walkthrough, & Zero-Error guide
├── scripts/
│   ├── ce_preflight_check.py          # Phase 1: Automated environment readiness check script
│   └── generate_demo_data.py          # Phase 3: Dynamic multi-table schema & synthetic data generator
├── skills/
│   └── generating-demo-data-for-looker/
│       └── SKILL.md                   # Phase 3: Custom Jetski skill for data discovery & BQ loading
└── templates/
    ├── custom_live_demo.md            # Phase 1 & 2: Data source selection & interactive prompt template
    ├── telecom_demo.md                # Phase 1 & 2: Telecom & 5G network performance analytics scenario
    ├── ecommerce_demo.md              # Phase 1 & 2: Pre-packaged E-Commerce prompt template
    └── saas_demo.md                   # Phase 1 & 2: Pre-packaged SaaS ARR prompt template
```

---

## ⚡ Quick Reference: How to Execute Each Phase

### Phase 1: Pre-Demo Readiness & Prompt Outline (Before Call)
1. **Verify Environment Health**: Run the pre-flight check script on Cloudtop:
```bash
python3 scripts/ce_preflight_check.py --connection-name {your_looker_bq_connection}
```
2. **Draft Prompt Outline**: Ahead of the meeting, select a template (e.g. `templates/telecom_demo.md` or `templates/custom_live_demo.md`) and pre-fill a general outline with your baseline approach and use-case assumptions so you come to the meeting prepared.

### Phase 2: Customer Alignment & Prompt Confirmation (Min 0–1 of call)
When you get on the call, walk through your pre-filled prompt template with the customer to confirm the general approach. Ask discovery questions and make any adjustments to the template on the fly before executing.

### Phase 3: Kick Off Agent & Tools Walkthrough (Mins 1–4 of call)
**Send prompt to Jetski Web at Minute 1**. Switch screen to your slides and walk through:
1. LookML Semantic Governance vs Raw LLM SQL
2. Looker Skills & Model Context Protocol (MCP Server)
3. Looker CLI (`looker-cli`) & Zero-Error Compiler Validation

### Phase 4: Reveal Dashboard (Min 4 of call)
Open the generated Looker URL returned by Jetski Web in your browser.

### Phase 5: Live Customer Iteration (Mins 4–10 of call)
Ask the customer for a live modification, and prompt **Jetski Web** to update the LookML/Dashboard in real time!

---

## ⚡ Zero Dead-Air Meeting Strategy

To eliminate presentation dead air while Jetski executes (~2–3 minutes), the CE **kicks off Jetski Web right at Minute 1**, then presents a 3-slide "Under the Hood Architecture" walkthrough (covering LookML governance, Looker Skills & MCP Server, and `looker-cli` compiler validation) while Jetski builds seamlessly in the background!

---

## 🛡️ What is "Zero-Error Compiler Validation"?

Unlike traditional LLM-to-SQL tools that generate un-verified text queries, Jetski executes an automated two-step quality assurance loop:
1. **Step 1: LookML Compiler Validation (`validate_project`)**: Jetski calls Looker's official compiler API using `looker-cli`. If the compiler reports any syntax error, missing join, or broken field reference, **Jetski intercepts the error log and self-heals by rewriting the LookML automatically** until Looker returns `0 errors`.
2. **Step 2: Inline SQL Runtime Verification**: Once compiled cleanly, Jetski executes a real test query against BigQuery (`runquery`) to prove that the underlying SQL executes without runtime database errors.

---