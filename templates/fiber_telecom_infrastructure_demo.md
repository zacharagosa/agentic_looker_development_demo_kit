# Demo Scenario Template: Enterprise Fiber & Optical Infrastructure Intelligence

## Business Context
Showcase how Looker and BigQuery deliver a mission-critical, end-to-end Network Operations Center (NOC) and Infrastructure Intelligence solution for an enterprise B2B fiber provider (hyperscale dark fiber, 400G wavelengths, carrier-neutral interconnects, and DWDM optical transport).

This demo highlights real-time optical signal degradation (dBm attenuation), automated contractual SLA risk calculations ($/hr exposure), BigQuery GIS fiber route line mapping (`ST_MAKELINE`), blast-radius impact analysis (`ST_BUFFER`), symmetric aggregates across fanout relationships, dynamic Liquid metric switching, and closed-loop operations with in-cell Looker Actions triggering Google Chat CardsV2 alerts.

---

## Pre-flight Setup
- **Data Source**: Option A (Agent-Generated Enterprise Telecom Schema) or Mode D (In-BigQuery SQL Generation)
- **Target GCP Project**: `{your_argolis_gcp_project_id}`
- **Target BigQuery Dataset**: `demo_fiber_telecom_analytics`
- **Looker Connection**: `{your_looker_bq_connection_name}`
- **Looker Project**: `fiber_infrastructure_analytics`
- **Google Chat Webhook (Optional for Closed-Loop Action)**: Incoming webhook URL from an operations room or test space.
- **Pre-Call Preparation**: Pre-populate dataset schema and verify BigQuery GIS functions (`ST_MAKELINE`, `ST_BUFFER`) before customer arrival.

---

## 🚀 Copy-Paste Live Demo Prompt for Jetski Web

Copy and paste the prompt below into **Jetski Web** during a customer presentation:

> "Jetski, we are building an Enterprise Fiber Network Intelligence & Automated NOC Operations solution for an enterprise telecommunications and fiber infrastructure provider.
> 
> Please execute the following end-to-end workflow:
> 
> 1. **Design a 5-table normalized relational fiber infrastructure schema**:
>    - `network_nodes`: (primary_key: `node_id`, `node_name`, `facility_type` [Carrier Hotel, Hyperscale Datacenter, ILA Regen Hut, Metro PoP], `city`, `state`, `latitude`, `longitude`, `chassis_capacity`, `status`)
>    - `fiber_spans`: (primary_key: `span_id`, foreign_key: `origin_node_id`, foreign_key: `terminus_node_id`, `span_name`, `fiber_type` [SMF-28 Ultra, Non-Zero Dispersion-Shifted LEAF], `strand_count`, `route_miles`, `attenuation_db_per_km`, `max_capacity_tbps`)
>    - `circuits`: (primary_key: `circuit_id`, foreign_key: `span_id`, `customer_segment` [Hyperscaler, Enterprise FinTech, Global CDN, Tier-2 Carrier], `circuit_type` [400G Wavelength, Dark Fiber Pair, 100G Optical Wave, Cloud Connect], `bandwidth_gbps`, `monthly_recurring_revenue`, `contracted_sla_pct` [99.999%, 99.99%, 99.9%], `status`)
>    - `optical_telemetry_logs`: (primary_key: `log_id`, foreign_key: `span_id`, foreign_key: `circuit_id`, `rx_optical_power_dbm`, `tx_optical_power_dbm`, `chromatic_dispersion_ps_nm`, `optical_snr_db`, `temperature_c`, `log_timestamp`)
>    - `network_incidents_outages`: (primary_key: `incident_id`, foreign_key: `span_id`, foreign_key: `circuit_id`, `root_cause` [Fiber Cut / Construction, Optical Attenuation / Microbend, DWDM Transponder Fault, Acoustic Vibration Alert, Power Interruption], `severity` [P1 - Critical, P2 - High, P3 - Medium], `status` [Active, Investigating, Splicing In-Progress, Resolved], `repair_cost_usd`, `estimated_sla_penalty_usd`, `time_to_restore_hours`, `reported_at`, `resolved_at`)
> 
> 2. **Ingest Synthetic Data into BigQuery**:
>    - Generate realistic synthetic records for all 5 tables preserving primary/foreign key relationships.
>    - Load tables into BigQuery dataset `demo_fiber_telecom_analytics` in project `{your_argolis_gcp_project_id}`.
> 
> 3. **Model Semantic Layer in LookML**:
>    - Create view files for all 5 entities.
>    - In `fiber_spans.view.lkml`, implement BigQuery GIS line geometry using:
>      `dimension: route_linestring { type: string sql: ST_ASTEXT(ST_MAKELINE(ST_GEOGPOINT(origin.longitude, origin.latitude), ST_GEOGPOINT(terminus.longitude, terminus.latitude))) ;; }`
>    - In `circuits.view.lkml`, implement an interactive Looker Action on `circuit_id` to escalate critical degradation alerts directly to the Google Chat NOC space:
>      ```lookml
>      dimension: circuit_id {
>        primary_key: yes
>        type: string
>        sql: ${TABLE}.circuit_id ;;
>        action: {
>          label: "🚨 Escalate to Google Chat NOC Room"
>          url: "https://your-webhook-dispatcher.run.app/dispatch-gchat-alert"
>          icon_url: "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/warning/default/48px.png"
>          form_param: {
>            name: "severity"
>            type: select
>            label: "Incident Severity"
>            option: { name: "CRITICAL" label: "P1 - Critical Outage" }
>            option: { name: "WARNING" label: "P2 - Degradation Risk" }
>            default: "CRITICAL"
>          }
>          form_param: {
>            name: "notes"
>            type: textarea
>            label: "Dispatch Notes for Field Technician"
>            default: "Optical Rx power below critical -22.0 dBm threshold. Immediate OTDR trace requested."
>          }
>        }
>      }
>      ```
>    - In `network_incidents_outages.view.lkml`, define LookML symmetric aggregates to prevent fanout duplication across one-to-many circuit/telemetry joins:
>      - `total_sla_penalties_exposed` (`type: sum`, `sql: ${TABLE}.estimated_sla_penalty_usd`, `value_format_name: usd_0`)
>      - `avg_time_to_restore` (`type: average`, `sql: ${TABLE}.time_to_restore_hours`, `value_format_name: decimal_1`)
>      - `total_incidents` (`type: count_distinct`, `sql: ${TABLE}.incident_id`)
>    - Implement dynamic Liquid parameter `operational_view_selector` allowing business stakeholders to toggle metric projections between 'Financial Risk ($)', 'Repair Velocity (MTTR)', and 'Signal Quality (Avg dBm)'.
> 
> 4. **Model Relationships & Compile**:
>    - Define Explore `fiber_spans` joined to `network_nodes` (origin and terminus aliased), `circuits`, `optical_telemetry_logs`, and `network_incidents_outages`.
>    - Validate project syntax with `validate_project`, test with an ad-hoc query, and deploy to production (`master`).
> 
> 5. **Deploy Looker Executive Dashboard**:
>    - Generate dashboard featuring:
>      * KPI Single Values: Active Fiber Route Miles, Total MRR at Risk, MTTR (Hours), Critical Optical Alarms.
>      * Multi-Measure Dual Y-Axis Chart: Monthly Outages vs Total SLA Penalty Exposure ($).
>      * BQ GIS Route Map: Dark Fiber & 400G spans colored by optical health.
>      * Incident Action Grid: In-cell Looker Action button enabling NOC operators to escalate directly to Google Chat."

---

## 🎙️ CE Presentation Narrative (Key Talking Points)

### 1. In-Database Geospatial Power (BigQuery GIS ➔ Looker)
> *"Unlike legacy BI tools that require separate GIS spatial servers, BigQuery calculates topological line geometries (`ST_MAKELINE`) and fiber outage blast buffers (`ST_BUFFER`) directly at Petabyte scale. Looker queries these natively, streaming geospatial line routes to the browser in sub-seconds."*

### 2. Multi-Hop Fanout Protection (LookML Symmetric Aggregates)
> *"In telecom networks, one physical span carries hundreds of multiplexed circuits, and each circuit produces thousands of telemetry pulses. In standard SQL, joining spans to circuits to telemetry inflates financial metrics by 100x. LookML solves this transparently with Symmetric Aggregates—calculating distinct primary key checksums automatically so executives never make multi-million-dollar decisions based on inflated SQL totals."*

### 3. Dynamic Liquid Parameterization
> *"Network directors care about fiber availability; CFOs care about SLA penalties and CAPEX recovery. Looker's Liquid parameterization dynamically restructures queries on the fly so a single tile morphs between financial, operational, and engineering perspectives without duplicating dashboards."*

### 4. Closed-Loop Operational Automation (Looker Actions ➔ Google Chat)
> *"Looker isn't just a place to admire charts—it is an operational control plane. With native Looker Actions, a NOC engineer reviewing an optical degradation alarm clicks directly on the circuit row to dispatch a rich Google Chat CardsV2 alert to field engineers, complete with route coordinates, optical loss readings, and a deep link back to the exact telemetry slice."*

---

## 💡 Live Customer Challenge & Objection Handling

#### Challenge 1: "We have fiber routes with millions of OTDR optical points. Won't browser rendering freeze?"
> **CE Response & Demo Move**:
> *"Looker leverages BigQuery's spatial clustering and server-side spatial aggregations (`ST_SIMPLIFY` / spatial grid binning). For dense metro runs, Looker queries the simplified vector at zoom level 10 and dynamically loads higher resolution nodes as the user zooms in, rendering 5,000+ segments smoothly."*

#### Challenge 2: "Our NOC team lives in Google Chat and Slack, not Looker dashboards. How does this help them?"
> **CE Response & Demo Move**:
> Run the zero-dependency dispatcher script `scripts/send_gchat_alert.py`:
> ```bash
> python3 scripts/send_gchat_alert.py --severity CRITICAL --circuit-id CKT-400G-CHI-DEN-0042 --rx-power "-28.4 dBm" --dry-run
> ```
> *"Looker integrates with your existing Chat rooms via Looker Actions and Scheduled Alerts. When optical attenuation breaches -22.0 dBm, Looker pushes a rich card into your Google Chat space with one-click drilldowns back into BigQuery."*

#### Challenge 3: "How does Looker handle metric definitions when our contract terms vary by customer tier?"
> **CE Response & Demo Move**:
> *"LookML models customer SLAs cleanly using conditional Liquid expressions or calculated dimensions. For instance, Tier-1 Hyperscalers have a 99.999% SLA with 10x hourly penalty multipliers, while Tier-2 carriers use standard credits. LookML encapsulates this logic in one central file, guaranteeing that revenue and billing audits always balance."*
