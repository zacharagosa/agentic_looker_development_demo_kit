# Demo Scenario Template: Paramount Global (Media & Entertainment: US Ad Spend & Nielsen Ratings Analytics)

## Business Context
Showcase how Looker and BigQuery empower **Paramount Global** with a unified, self-service commercial intelligence and audience ratings analytics platform. This demo demonstrates how media planners, sales executives, and upfront agency partners analyze US advertising spend ($ USD), Nielsen audience ratings (GRPs, TRPs, Reach, CPP), and commercial spot airings across premier broadcast, cable, and streaming brands (*CBS*, *Paramount+*, *Nickelodeon*, *MTV*, *Comedy Central*, *Showtime*, and *CBS Sports*).

### Key Highlights Demonstrated in this Demo:
1. **Looker Self-Service Capabilities**:
   - **Dynamic Metric Selector (Liquid Parameters)**: Switch entire dashboards and explores between *Ad Spend ($ USD)*, *Gross Rating Points (GRP)*, *Target Rating Points (TRP)*, *Cost Per Point (CPP $ USD)*, *Audience Reach %*, and *Impressions* with a single dropdown.
   - **Curated Media Explores & Drill Hierarchies**: Seamless drill paths (*Network ➔ Show ➔ Daypart ➔ Commercial Spot Airing* and *US State ➔ Designated Market Area [DMA]*).
   - **Interactive Cross-Filtering & Data Actions**: Instant slice-and-dice across genres (Live Sports, Westerns & Dramas, Late Night & Comedy, Animation, Reality), advertisers, and dayparts with 1-click **[📈 Adjust Rate Card]**, **[📧 Dispatch Agency Alert]**, and **[💬 Google Chat Escalation]** Data Actions.
2. **Advanced BigQuery Capabilities**:
   - **BigQuery Vector Search (`VECTOR_SEARCH`)**: Natural language **Contextual Ad Placement Search** that semantically matches advertiser creative themes to TV show scripts and synopses (e.g. *'NFL football with beer wings and tailgating'*, *'prestige western ranch drama'*, or *'kids animation toys and breakfast cereal'*).
   - **BigQuery ML Predictive Ratings & Anomaly Detection (`ARIMA_PLUS`)**: Forward-looking 30-to-60 day predictive time-series forecasting with 95% confidence intervals contrasting against upfront contractual guarantees to preemptively eliminate make-good liabilities.
   - **Regional DMA Telemetry**: Regional Nielsen rating distribution and ad spend density across top US media markets (New York, Los Angeles, Chicago, Philadelphia, Dallas-Fort Worth, Atlanta, Houston, Washington DC).

---

## Live Deployed Dashboards & Explores
- **Looker Instance**: `https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app`
- **Looker Project**: `paramount_media_analytics`
- **Database Connection**: `looker-private-demo`
- **Live User-Defined Dashboards (UDDs)**:
  - **[Dashboard 170: Paramount Commercial Intelligence & Nielsen Ratings Overview](https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/dashboards/170)**
    - Tab 1: `📊 Commercial Overview`
    - Tab 2: `📺 Ratings & Dayparts`
    - Tab 3: `🤖 AI Ad-Ops & Make-Goods`
    - Tab 4: `🔮 BQML Predictive Ratings (ARIMA_PLUS)`
  - **[Dashboard 171: Paramount AI Contextual Ad Placement Matcher (BigQuery Vector Search)](https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/dashboards/171)**
    - Interactive natural language RFP theme matcher powered by in-database cosine similarity.

---

## 🚀 Copy-Paste Live Demo Prompt for Jetski Web / Antigravity

Copy and paste the exact prompt below into **Jetski Web** or **Antigravity 2.0** during a live customer demo:

```text
Build a complete Commercial Intelligence & Audience Ratings Analytics solution for an Executive VP of Ad Sales & Upfront Commercial Operations at Paramount Global.

Please execute the following end-to-end workflow:

1. Relational Schema & Entity Modeling:
   - Program Catalog: CBS, Paramount+ (Streaming), CBS Sports, Nickelodeon, Comedy Central, MTV, Showtime.
   - Flagship Shows: NFL on CBS, Yellowstone, 1923, Survivor, Tracker, FBI, 60 Minutes, SpongeBob SquarePants, PAW Patrol, South Park, The Daily Show, MTV VMAs, Billions, Special Ops: Lioness.
   - Key Advertisers: Procter & Gamble, General Motors, PepsiCo, Amazon, T-Mobile, Pfizer, Geico, Target.
   - US DMA Markets: New York (DMA 1), Los Angeles (DMA 2), Chicago (DMA 3), Philadelphia (DMA 4), Dallas-Fort Worth (DMA 5), Atlanta (DMA 6), Houston (DMA 7), Washington DC (DMA 8).
   - Core Demographics: Total Persons 2+, Adults 18-49 (Commercial Upfront Demo), Adults 25-54, Women 25-54, Men 18-34.

2. Build LookML Semantic Layer in Project `paramount_media_analytics`:
   - Connection: `looker-private-demo`
   - Implement Dynamic Metric Selector parameter (`metric_selector`) with dynamic Liquid measure `dynamic_metric_value`.
   - Core Measures: Total Commercial Spend ($ USD), Total GRPs, Total TRPs, Average CPP ($ USD), Total Impressions (000s), Under-Delivery Make-Good Alerts, and Make-Good Financial Risk ($ USD).
   - BigQuery Vector Search: Derived view `contextual_ad_search` matching natural language creative themes (e.g., 'NFL football with beer wings and tailgating') to show synopses using cosine similarity.
   - BigQuery ML ARIMA_PLUS: Derived view `nielsen_ratings_forecast` projecting 30-60 day ratings with 95% confidence intervals and contractual upfront guarantees.

3. Validate, Deploy & Deliver:
   - Validate project with zero compiler errors.
   - Deploy to production.
   - Provide multi-tab dashboard with Commercial Overview, Ratings & Dayparts, AI Ad-Ops & Make-Goods, and BQML Predictive Ratings.
```

---

## 🎙️ CE Presentation Narrative (What to Say During the Pitch)

### Minute 1: The Upfront Governance Challenge
> *"In enterprise media organizations like Paramount Global, commercial operations manage billions of dollars across linear broadcast (CBS), cable tentpoles (MTV, Comedy Central, Nickelodeon), and streaming (Paramount+). Sales talks about Gross Spend, media planners focus on Gross Rating Points (GRP) and Cost Per Point (CPP), while research tracks Unduplicated Reach. LookML locks down these cross-platform formulas once in a governed semantic layer, ensuring that whether an executive looks at a dashboard or queries an AI agent, the numbers match down to the cent."*

### Minute 2: Looker Self-Service Interactivity
> *"Notice how Looker empowers non-technical upfront buyers and sales planners:*
> - * **Dynamic Metric Selector**: With a single click on our metric selector dropdown, every tile on the dashboard seamlessly pivots between Commercial Spend ($ USD), GRPs, TRPs, and Cost Per Point.*
> - * **Audience Delivery Drill Paths**: A planner can click 'CBS' ➔ drill into 'NFL on CBS' ➔ drill into 'Prime Time' ➔ and see the specific spot airings across the New York or Los Angeles DMAs.*
> - * **Demographic Reach vs. TRP Weighting**: Looker cleanly separates delivery across core buying demographics—showing how Women 25-54 dominate daytime and prime procedurals, while Men 18-34 surge during live NFL on CBS."*

### Minute 3: Real-Time Make-Good Resolution & 1-Click Ad-Ops
> *"When a live event or mid-season show under-delivers ratings, network agreements require compensatory 'make-goods'. Looker connects directly to BigQuery anomaly detection to identify under-delivering spots in real time. Ad-ops managers can click **[🎯 Issue Make-Good]** or **[💬 Post to Google Chat]** directly from a table row to reallocate scatter inventory across CBS or Paramount+ streaming impressions in seconds."*

### Minute 4: In-Database AI with BigQuery Vector Search & ARIMA_PLUS
> *"Looker doesn't just display static historical charts—it leverages Google Cloud's AI engine directly in BigQuery:*
> 1. * **Contextual Creative Matching**: Advertisers pay a 15% to 25% premium for contextual relevancy. An agency buyer can type 'NFL tailgating with beer and wings' or 'prestige western ranch drama', and BigQuery's native `VECTOR_SEARCH` instantly surfaces and ranks the most relevant Paramount programming.*
> 2. * **30-Day Forward-Looking Forecasting**: Using BigQuery ML `ARIMA_PLUS`, Paramount forecasts ratings 30 to 60 days into the future with 95% confidence intervals, allowing commercial directors to preemptively adjust rate cards weeks before an upfront liability occurs."*

---

## 🎯 Verified Golden Queries for Conversational Analytics

Use these verified Question and Explore URL pairs to configure Looker's Conversational Analytics Agent:

### 1. Network Commercial Spend & Ratings Performance
- **Question**: `What is our total commercial ad spend, total GRPs, and average CPP by broadcast network?`
- **Explore URL**:
  ```text
  https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/explore/paramount_media_analytics/ad_spot_airings?fields=broadcast_programming.network,ad_spot_airings.total_spend_usd,nielsen_ratings_markets.total_grps,nielsen_ratings_markets.average_cpp_usd&sorts=ad_spot_airings.total_spend_usd+desc&limit=500
  ```

### 2. Prime Time Top Programming Delivery
- **Question**: `Which broadcast TV shows delivered the highest TRPs and reach in Prime Time?`
- **Explore URL**:
  ```text
  https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/explore/paramount_media_analytics/ad_spot_airings?fields=broadcast_programming.show_title,broadcast_programming.network,nielsen_ratings_markets.total_trps,nielsen_ratings_markets.average_reach_pct,ad_spot_airings.total_spend_usd&f[ad_spot_airings.daypart]=Prime+Time+%288-11+PM+EST%29&sorts=nielsen_ratings_markets.total_trps+desc&limit=15
  ```

### 3. Make-Good Financial Risk & Under-Delivery Backlog
- **Question**: `What is our total make-good cost risk and under-delivery spot count by network?`
- **Explore URL**:
  ```text
  https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/explore/paramount_media_analytics/ad_spot_airings?fields=broadcast_programming.network,nielsen_ratings_markets.under_delivery_spot_count,nielsen_ratings_markets.make_good_cost_risk_usd,nielsen_ratings_markets.under_delivery_rate&f[nielsen_ratings_markets.anomaly_type]=Under-delivery+Alert&sorts=nielsen_ratings_markets.make_good_cost_risk_usd+desc&limit=500
  ```

### 4. Demographic Audience Reach Comparison
- **Question**: `Compare target rating points (TRPs) and average reach percentage across demographic segments.`
- **Explore URL**:
  ```text
  https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/explore/paramount_media_analytics/ad_spot_airings?fields=nielsen_ratings_markets.target_demographic,nielsen_ratings_markets.total_trps,nielsen_ratings_markets.average_reach_pct&sorts=nielsen_ratings_markets.total_trps+desc&limit=500
  ```

### 5. Advertiser Commercial Spend Across Dayparts
- **Question**: `Show me the top advertisers and their commercial spend breakdown across broadcast dayparts.`
- **Explore URL**:
  ```text
  https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/explore/paramount_media_analytics/ad_spot_airings?fields=advertiser_campaigns.advertiser_name,ad_spot_airings.daypart,ad_spot_airings.total_spend_usd,ad_spot_airings.total_airing_spots&sorts=ad_spot_airings.total_spend_usd+desc&limit=20
  ```
