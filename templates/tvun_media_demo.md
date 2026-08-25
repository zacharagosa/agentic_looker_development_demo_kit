# Demo Scenario Template: TVUN (Media & Entertainment: Mexican Ad Spend & Nielsen Ratings Analytics)

## Business Context
Showcase how Looker and BigQuery empower **TVUN (TelevisaUnivision)** with a unified, self-service commercial intelligence and audience ratings analytics platform. This demo demonstrates how media planners, sales executives, and programming directors analyze Mexican advertising spend ($ MXN), Nielsen/IBOPE audience ratings (GRPs, TRPs, Reach, CPP), and spot airings across premier networks (*Las Estrellas*, *Canal 5*, *TUDN*, *Univision*, *Nu9ve*, *ViX*).

### Key Highlights Demonstrated in this Demo:
1. **Looker Self-Service Capabilities**:
   - **Dynamic Metric Selector (Liquid Parameters)**: Switch entire dashboards and explores between *Ad Spend ($ MXN)*, *Gross Rating Points (GRP)*, *Target Rating Points (TRP)*, *Cost Per Point (CPP)*, and *Impressions* with a single dropdown.
   - **Curated Media Explores & Drill Hierarchies**: Seamless drill paths (*Network ➔ Show ➔ Daypart ➔ Ad Spot Airing* and *Mexican State ➔ Nielsen DMA Market*).
   - **Interactive Cross-Filtering**: Instant slice-and-dice across genres (Telenovelas, Sports, News), advertisers, and dayparts.
2. **Advanced BigQuery Capabilities**:
   - **BigQuery Vector Search (`VECTOR_SEARCH`)**: Natural language **Contextual Ad Placement Search** that semantically matches advertiser creative themes to TV show scripts/synopses.
   - **BigQuery ML Anomaly Detection (`ML.DETECT_ANOMALIES`)**: Real-time identification of rating point under-deliveries and ad spend pacing anomalies to automate advertiser "make-good" compensations.
   - **BigQuery Geospatial Analytics**: Regional Nielsen rating distribution and ad spend density across Mexican states (CDMX, Jalisco, Nuevo León, Puebla, etc.).

---

## Pre-flight Setup
- **Data Source**: Option A (Dynamic Agent-Generated TVUN Media & Nielsen Schema)
- **Target GCP Project**: `{your_argolis_gcp_project_id}`
- **Target BigQuery Dataset**: `demo_tvun_media_analytics`
- **Looker Connection**: `{your_looker_bq_connection_name}`
- **Looker Project**: `tvun_media_analytics`

---

## 🚀 Copy-Paste Live Demo Prompt for Jetski Web

Copy and paste the exact prompt below into **Jetski Web** during a customer call:

```text
Jetski, we are building a live Commercial Intelligence & Audience Ratings Analytics solution for a VP of Ad Sales & Commercial Operations at TVUN (TelevisaUnivision).

Please execute the following end-to-end workflow:

1. Design an enterprise media & ratings relational schema for the following 4 tables:
   - `advertiser_campaigns` (primary_key: `campaign_id`, `advertiser_name` [Grupo Bimbo, América Móvil / Telcel, Cerveza Corona, Banorte, Coca-Cola FEMSA, Coppel, Nissan México], `agency` [Omnicom, WPP, Publicis, Dentsu, Havas], `industry_category` [CPG, Telecom, Beverages, Financial Services, Retail, Automotive], `total_budget_mxn`, `flight_start_date`, `flight_end_date`)
   - `broadcast_programming` (primary_key: `show_id`, `show_title` [Liga MX: Clásico Nacional, La Rosa de Guadalupe, Noticiero Univision, La Casa de los Famosos México, Telenovela: El Amor Invencible, TUDN Fútbol Club, Canal 5 Cine Prime], `network` [Las Estrellas, Canal 5, TUDN, Univision, Nu9ve, ViX], `genre` [Sports, Telenovela, News, Reality, Comedy, Movies], `content_synopsis`, `content_embedding` [ARRAY<FLOAT64> 8-dimensional vector embedding for semantic search])
   - `ad_spot_airings` (primary_key: `spot_id`, foreign_key: `campaign_id`, foreign_key: `show_id`, `airing_timestamp`, `daypart` [Prime Time (Horario Estelar), Daytime (Vespertino), Early Morning (Matutino), Late Night (Nocturno)], `spot_duration_sec` [20s, 30s, 60s], `rate_card_mxn`, `spot_cost_mxn`)
   - `nielsen_ratings_markets` (primary_key: `rating_id`, foreign_key: `spot_id`, `mexican_market` [CDMX, Guadalajara, Monterrey, Tijuana, Puebla, León, Mérida, Querétaro], `mexican_state` [Ciudad de México, Jalisco, Nuevo León, Baja California, Puebla, Guanajuato, Yucatán, Querétaro], `target_demographic` [Adultos 18-49, Mujeres 25-54, Hombres 18-34, Total Personas 4+], `gross_rating_points_grp`, `target_rating_points_trp`, `impressions_thousands`, `reach_percentage`, `cost_per_point_cpp`, `is_anomaly_detected` [true, false], `anomaly_type` [Under-delivery Alert, Rating Surge, Normal])

2. Natively generate production-scale synthetic data directly inside BigQuery (DO NOT write local CSV files):
   Create dataset `demo_tvun_media_analytics` in project `{your_argolis_gcp_project_id}`.
   Execute BigQuery DDL statements using `GENERATE_ARRAY()` and `FARM_FINGERPRINT()` or `MOD()` arithmetic to populate the tables at the following scales:
   - `broadcast_programming`: ~50 shows with realistic Mexican programming synopses and normalized 8-dim semantic embeddings.
   - `advertiser_campaigns`: ~2,500 active Mexican advertiser campaigns.
   - `ad_spot_airings`: ~1,000,000 ad spot airings distributed across networks, dayparts, and the past 365 days.
   - `nielsen_ratings_markets`: ~4,000,000 rating observations across the 8 Mexican DMA markets (seed with ~8% anomaly detection rate for under-delivery make-goods).

3. Build LookML Views & Semantic Layer with Self-Service & BigQuery AI capabilities:
   - Create LookML view files for all 4 tables declaring primary keys, dimensions, and standard drill fields.
   - Self-Service Feature: Build a Dynamic Metric Selector Parameter in LookML (`parameter: metric_selector`) with allowed values: "Spend (MXN)", "GRPs", "TRPs", "CPP (MXN)", "Impressions" and a dynamic Liquid measure `dynamic_metric_value` that dynamically switches label, calculation, and value format based on user selection.
   - Core Measures:
     - `total_spend_mxn` (sum of spot_cost_mxn, format: currency MXN)
     - `total_grps` (sum of gross_rating_points_grp, format: decimal_1)
     - `total_trps` (sum of target_rating_points_trp, format: decimal_1)
     - `average_cpp_mxn` (`total_spend_mxn / nullif(total_grps, 0)`, format: currency MXN)
     - `total_impressions_thousands` (sum of impressions_thousands)
     - `under_delivery_spot_count` (count distinct spot_id where anomaly_type = 'Under-delivery Alert')
     - `make_good_cost_risk_mxn` (sum of spot_cost_mxn for under-delivering spots)
   - Advanced BQ Feature (Vector Search Derived Table): Create a derived LookML view `contextual_ad_search` utilizing BigQuery `VECTOR_SEARCH` with a user search parameter `search_theme` to enable natural language matching of advertiser campaign concepts to broadcast programming.

4. Create Model & Validate:
   - Create model file `tvun_media_analytics.model.lkml` joining `ad_spot_airings`, `advertiser_campaigns`, `broadcast_programming`, and `nielsen_ratings_markets`.
   - Include the `contextual_ad_search` explore.
   - Map the model to connection `{your_looker_bq_connection_name}`.
   - Run LookML compiler validation (`validate_project`) and execute an inline test query against BigQuery, and deploy the project to production.

5. Generate Looker Dashboard:
   - Create a LookML dashboard `tvun_commercial_ratings_overview` with tiles for:
     1. Executive KPI Header: Total Ad Spend (MXN), Total GRPs Delivered, Average CPP (MXN), Total Impressions, and Under-Delivery Make-Good Alerts.
     2. Revenue & Rating Trends by Network (Las Estrellas vs Canal 5 vs TUDN vs Univision vs ViX).
     3. Daypart Mix Matrix (Prime Time vs Daytime vs Late Night).
     4. Regional Market Performance Map (CDMX, Guadalajara, Monterrey, Puebla).
     5. Make-Good Risk & Anomaly Watchlist Table.
   - Import the dashboard as a User-Defined Dashboard (UDD) in Looker and return the live URL.
```

---

## 🎙️ CE Presentation Narrative (What to Say While Jetski Builds)

*Use this narrative during the Minute 1 to Minute 4 build window while showing your architecture slides:*

### Slide 1: The Media Governance Problem (LookML vs. Disjointed Spreadsheets)
> *"In media organizations like TelevisaUnivision, commercial operations struggle with metric discrepancies. Sales talks about Total Ad Spend ($ MXN), media buyers talk about Gross Rating Points (GRP) and Cost Per Point (CPP), while research analyzes Net Reach. When these live in disconnected spreadsheets or raw SQL scripts, you get 5 different definitions of an 'under-delivering spot'. LookML locks down these complex broadcast formulas once in a governed semantic layer."*

### Slide 2: Empowering Non-Technical Media Planners with Looker Self-Service
> *"Looker enables true self-service for agency planners and commercial directors:*
> - * **Dynamic Metric Selector**: Notice how a user can switch the entire report between Spend (MXN), TRPs, or Impressions with a single dropdown—no SQL rewrite required.*
> - * **1-Click Drill Paths**: A planner can click on 'Las Estrellas' ➔ drill directly into 'Liga MX' ➔ drill into 'Prime Time' ➔ and see the individual spot airings in CDMX or Monterrey.*
> - * **Cross-Filtering**: Clicking on any Mexican state or genre instantly filters all audience delivery tiles across the screen."*

### Slide 3: BigQuery Advanced Intelligence (Vector Search & Native Anomaly Detection)
> *"We aren't just doing basic BI reporting. Looker pushes down into BigQuery's advanced AI engine:*
> 1. * **Contextual Ad Matching with BigQuery Vector Search**: Brand advertisers pay top dollar for contextual relevancy. An agency buyer can type 'botanas y fútbol mexicano' into Looker, and BigQuery's native `VECTOR_SEARCH` instantly ranks the highest-matching broadcast programming synopses.*
> 2. * **Automated Make-Good Anomaly Detection**: BigQuery automatically flags under-delivering TRPs in real time, alerting commercial teams before the flight ends so they can issue make-good compensatory spots."*

---

## 💡 Live Customer Challenge & Iteration Examples (Phase 5)

Once the dashboard link opens live in front of the TVUN team, hand them the steering wheel:

* **The Self-Service Dynamic Parameter Challenge**:  
  > *"Jetski, switch the primary dashboard metric parameter from 'Ad Spend (MXN)' to 'Target Rating Points (TRP)' and show the regional delivery for Adults 18-49."*

* **The BigQuery Vector Search Challenge**:  
  > *"Jetski, use Vector Search to find the top 5 TV programming matches for an advertiser prompt: 'drama romántico con cenas y cocina mexicana' and show available prime-time inventory."*

* **The Commercial Make-Good Challenge**:  
  > *"Jetski, filter the Make-Good Risk table for Grupo Bimbo campaigns in CDMX and Monterrey that had rating point under-delivery anomalies, and calculate total required compensatory impressions."*
