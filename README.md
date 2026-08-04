# Looker CE Agentic Demo Kit: Master Overview & 5-Phase Playbook

Welcome to the **Looker Customer Engineering Agentic Demo Kit**. This kit equips CEs to deliver live, end-to-end demonstrations showing how **Looker** powered by Agentic AI accelerates BI development from zero to an interactive dashboard in minutes.

---

## 🗺️ Looker Demo Steps

- **Phase 1: Pre-Demo Readiness & Prompt Outline (Before Call)**  
  Run the pre-flight check script on Cloudtop (`scripts/ce_preflight_check.py`) and pre-fill a prompt template outline with your planned approach and use-case assumptions.
- **Phase 2: Customer Alignment & Prompt Confirmation (Start of Call)**  
  Walk through the pre-filled prompt template with the customer to confirm the approach, asking discovery questions and adjusting the prompt on the fly before executing.
- **Phase 3: Kick Off Agent & "Under the Hood" Tools Walkthrough (During Agent Execution)**  
  **Kick off Jetski Web immediately after alignment**. While the agent builds in the background, present the 3 key architecture tools:
  1. Looker Semantic Layer (LookML) vs Raw LLM SQL
  2. Looker Skills & Model Context Protocol (MCP Server)
  3. Looker CLI (`looker-cli`) & Zero-Error Compiler Validation
- **Phase 4: Reveal Generated Looker Dashboard (Dashboard Reveal)**  
  Open the completed User-Defined Dashboard (UDD) link live in your Argolis Looker UI.
- **Phase 5: Live Dashboard Demo & Real-Time Customer Iteration (Live Iteration)**  
  Invite customer challenges and prompt Jetski Web to make real-time LookML and dashboard edits on the fly.

---

## 📂 Kit Directory & Tools Index

```
looker-ce-demo-kit/
├── README.md                          # Master overview & 5-phase demo journey
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

### Phase 2: Customer Alignment & Prompt Confirmation (Start of Call)
When you get on the call, walk through your pre-filled prompt template with the customer to confirm the general approach. Ask discovery questions and make any adjustments to the template on the fly before executing.

### Phase 3: Kick Off Agent & Tools Walkthrough (During Agent Execution)
**Send prompt to Jetski Web immediately after alignment**. Switch screen to your slides and walk through:
1. LookML Semantic Governance vs Raw LLM SQL
2. Looker Skills & Model Context Protocol (MCP Server)
3. Looker CLI (`looker-cli`) & Zero-Error Compiler Validation

### Phase 4: Reveal Dashboard (Dashboard Reveal)
Open the generated Looker URL returned by Jetski Web in your browser.

### Phase 5: Live Customer Iteration (Live Iteration)
Ask the customer for a live modification, and prompt **Jetski Web** to update the LookML/Dashboard in real time!