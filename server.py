"""QBR Studio — automated quarterly business reviews on Looker.

Four experiences:
  /                  pick a rep or a manager
  /qbr/<rep_id>      the generated QBR deck (Gemini prose over Looker figures)
  /dive/<rep_id>     deep dive — embedded Looker dashboards
  /team/<mgr_id>     manager roll-up across the whole team
  /ask               Conversational Analytics chat with the Gemini QBR Advisor agent
"""

import functools
import os
import time
import traceback

from flask import Flask, jsonify, render_template, request

import looker_client as lk
import narrative

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False

import json

PORT = int(os.getenv("PORT", "8092"))
COVERAGE_TARGET = 3.0
FAST_CACHE_PATH = os.path.join(os.path.dirname(__file__), "cache", "qbr_fast_cache.json")
_FAST_CACHE = {"mtime": 0, "data": {"reps": {}, "managers": {}}}


def get_fast_cache():
    try:
        if os.path.exists(FAST_CACHE_PATH):
            mtime = os.path.getmtime(FAST_CACHE_PATH)
            if mtime > _FAST_CACHE["mtime"]:
                with open(FAST_CACHE_PATH, "r") as f:
                    _FAST_CACHE["data"] = json.load(f)
                _FAST_CACHE["mtime"] = mtime
    except Exception as e:
        print(f"[server] fast cache read warning: {e}")
    return _FAST_CACHE["data"]


def save_fast_cache(data):
    try:
        os.makedirs(os.path.dirname(FAST_CACHE_PATH), exist_ok=True)
        with open(FAST_CACHE_PATH, "w") as f:
            json.dump(data, f)
        _FAST_CACHE["data"] = data
        _FAST_CACHE["mtime"] = os.path.getmtime(FAST_CACHE_PATH)
    except Exception as e:
        print(f"[server] fast cache write warning: {e}")



# --------------------------------------------------------------------------
# Small TTL cache — the roster and quarter label change once a quarter, and
# re-querying them on every page load makes the app feel sluggish.
# --------------------------------------------------------------------------
def ttl_cache(seconds):
    def deco(fn):
        store = {}

        @functools.wraps(fn)
        def wrapper(*args):
            now = time.time()
            hit = store.get(args)
            if hit and now - hit[0] < seconds:
                return hit[1]
            val = fn(*args)
            store[args] = (now, val)
            return val

        wrapper.cache_clear = store.clear
        return wrapper

    return deco


@ttl_cache(900)
def current_quarter():
    rows = lk.run_query(
        "qbr_performance",
        ["qbr_rep_quota.fiscal_quarter_label"],
        {"qbr_rep_quota.is_current_quarter": "Yes"},
        limit=1,
    )
    return rows[0]["qbr_rep_quota.fiscal_quarter_label"] if rows else "2026-Q3"


@ttl_cache(900)
def roster():
    """Every quota-carrying rep in the current quarter, with their headline number."""
    q = current_quarter()
    rows = lk.run_query(
        "qbr_performance",
        [
            "qbr_rep_roster.rep_id",
            "qbr_rep_roster.rep_name",
            "qbr_rep_roster.manager_id",
            "qbr_rep_roster.manager_name",
            "qbr_rep_roster.team_name",
            "qbr_rep_roster.segment",
            "qbr_rep_roster.region",
            "qbr_rep_roster.ramp_status",
            "qbr_rep_quota.total_arr_quota",
            "qbr_rep_performance.total_won_arr",
            "qbr_rep_quota.arr_attainment",
        ],
        {"qbr_rep_quota.fiscal_quarter_label": q},
        ["qbr_rep_quota.arr_attainment desc"],
        limit=500,
    )
    out = []
    for r in rows:
        out.append(
            {
                "rep_id": r["qbr_rep_roster.rep_id"],
                "rep_name": r["qbr_rep_roster.rep_name"],
                "manager_id": r["qbr_rep_roster.manager_id"],
                "manager_name": r["qbr_rep_roster.manager_name"],
                "team_name": r["qbr_rep_roster.team_name"],
                "segment": r["qbr_rep_roster.segment"],
                "region": r["qbr_rep_roster.region"],
                "ramp_status": r["qbr_rep_roster.ramp_status"],
                "quota": r["qbr_rep_quota.total_arr_quota"] or 0,
                "won": r["qbr_rep_performance.total_won_arr"] or 0,
                "attainment": r["qbr_rep_quota.arr_attainment"] or 0,
            }
        )
    return out


@ttl_cache(900)
def managers():
    seen = {}
    for r in roster():
        m = seen.setdefault(
            r["manager_id"],
            {
                "manager_id": r["manager_id"],
                "manager_name": r["manager_name"],
                "team_name": r["team_name"],
                "headcount": 0,
                "quota": 0.0,
                "won": 0.0,
            },
        )
        m["headcount"] += 1
        m["quota"] += float(r["quota"] or 0)
        m["won"] += float(r["won"] or 0)
    out = list(seen.values())
    for m in out:
        m["attainment"] = (m["won"] / m["quota"]) if m["quota"] else 0
    out.sort(key=lambda m: m["attainment"], reverse=True)
    return out


def find_rep(rep_id):
    return next((r for r in roster() if str(r["rep_id"]) == str(rep_id)), None)


def find_manager(manager_id):
    return next(
        (m for m in managers() if str(m["manager_id"]) == str(manager_id)), None
    )


# --------------------------------------------------------------------------
# Figure gathering
# --------------------------------------------------------------------------
def rep_facts(rep_id, quarter):
    """Everything the QBR deck and the narrative layer need for one rep."""
    name_filter = {"qbr_rep_roster.rep_id": str(rep_id)}
    qf = dict(name_filter, **{"qbr_rep_quota.fiscal_quarter_label": quarter})

    perf = lk.one(
        "qbr_performance",
        [
            "qbr_rep_quota.total_arr_quota",
            "qbr_rep_performance.total_won_arr",
            "qbr_rep_quota.arr_attainment",
            "qbr_rep_quota.quota_gap",
            "qbr_rep_quota.quota_remaining",
            "qbr_rep_quota.pipeline_coverage_ratio",
            "qbr_rep_performance.total_new_logo_arr",
            "qbr_rep_performance.total_expansion_arr",
            "qbr_rep_performance.won_deal_count",
            "qbr_rep_performance.lost_deal_count",
            "qbr_rep_performance.win_rate",
            "qbr_rep_performance.average_won_deal_arr",
            "qbr_rep_performance.average_sales_cycle",
            "qbr_rep_performance.total_open_pipeline_arr",
            "qbr_rep_performance.total_commit_arr",
            "qbr_rep_performance.total_high_risk_arr",
            "qbr_rep_performance.total_zombie_arr",
            "qbr_rep_performance.total_questionable_commit_arr",
            "qbr_rep_performance.created_deal_count",
            "qbr_rep_performance.activities_per_won_deal",
        ],
        qf,
    )

    trend = lk.run_query(
        "qbr_performance",
        [
            "qbr_rep_quota.fiscal_quarter_label",
            "qbr_rep_quota.total_arr_quota",
            "qbr_rep_performance.total_won_arr",
            "qbr_rep_quota.arr_attainment",
        ],
        name_filter,
        ["qbr_rep_quota.fiscal_quarter_label"],
        limit=12,
    )

    deals = lk.run_query(
        "qbr_pipeline_inspection",
        [
            "qbr_deal_quality.opportunity_name",
            "qbr_deal_quality.stage_name",
            "qbr_deal_quality.forecast_category",
            "qbr_deal_quality.close_date",
            "qbr_deal_quality.slip_count",
            "qbr_deal_quality.days_in_current_stage",
            "qbr_deal_quality.days_since_last_activity",
            "qbr_deal_quality.risk_band",
            "qbr_deal_quality.risk_score",
            "qbr_deal_quality.open_arr",
        ],
        {"qbr_rep_roster.rep_id": str(rep_id), "qbr_deal_quality.is_closed": "No"},
        ["qbr_deal_quality.open_arr desc"],
        limit=10,
    )

    risk_summary = lk.one(
        "qbr_customer_risk",
        [
            "qbr_account_risk.total_active_arr",
            "qbr_account_risk.total_arr_at_risk",
            "qbr_account_risk.percent_arr_at_risk",
            "qbr_account_risk.high_risk_account_count",
            "qbr_account_risk.account_count",
            "qbr_account_risk.average_utilization",
            "qbr_account_risk.renewal_arr_180d",
            "qbr_account_risk.average_risk_score",
            "qbr_account_risk.average_csat",
            "qbr_account_risk.total_tickets_90d",
        ],
        {"qbr_rep_roster.rep_id": str(rep_id)},
    )

    accounts = lk.run_query(
        "qbr_customer_risk",
        [
            "qbr_account_risk.account_name",
            "qbr_account_risk.industry",
            "qbr_account_risk.utilization_pct",
            "qbr_account_risk.usage_trend_pct",
            "qbr_account_risk.is_usage_declining",
            "qbr_account_risk.active_users_30d",
            "qbr_account_risk.named_users",
            "qbr_account_risk.tickets_90d",
            "qbr_account_risk.avg_csat_180d",
            "qbr_account_risk.days_to_renewal",
            "qbr_account_risk.risk_band",
            "qbr_account_risk.risk_score",
            "qbr_account_risk.total_active_arr",
        ],
        {"qbr_rep_roster.rep_id": str(rep_id)},
        ["qbr_account_risk.risk_score desc"],
        limit=12,
    )

    g = perf.get
    raw_quota = float(g("qbr_rep_quota.total_arr_quota") or 0)
    raw_pipe = float(g("qbr_rep_performance.total_open_pipeline_arr") or 0)
    raw_cov = float(g("qbr_rep_quota.pipeline_coverage_ratio") or 0)
    if raw_cov <= 0 and raw_quota > 0:
        raw_cov = raw_pipe / raw_quota

    avg_risk = float(risk_summary.get("qbr_account_risk.average_risk_score") or 28.0)
    health_score = max(0, min(100, int(round(100.0 - avg_risk))))
    declining_cnt = sum(
        1 for a in accounts
        if float(a.get("qbr_account_risk.usage_trend_pct") or 0) < 0
        or str(a.get("qbr_account_risk.is_usage_declining") or "").lower() == "yes"
    )
    expansion_cnt = sum(
        1 for a in accounts
        if float(a.get("qbr_account_risk.utilization_pct") or 0) >= 0.80
    )
    trends = [float(a.get("qbr_account_risk.usage_trend_pct") or 0) for a in accounts]
    avg_trend = (sum(trends) / len(trends)) if trends else 0.0

    return {
        "quota": raw_quota,
        "won": g("qbr_rep_performance.total_won_arr") or 0,
        "attainment": g("qbr_rep_quota.arr_attainment") or 0,
        "quota_gap": g("qbr_rep_quota.quota_gap") or 0,
        "quota_remaining": g("qbr_rep_quota.quota_remaining") or 0,
        "pipeline_coverage": raw_cov,
        "new_logo_arr": g("qbr_rep_performance.total_new_logo_arr") or 0,
        "expansion_arr": g("qbr_rep_performance.total_expansion_arr") or 0,
        "won_deals": g("qbr_rep_performance.won_deal_count") or 0,
        "lost_deals": g("qbr_rep_performance.lost_deal_count") or 0,
        "win_rate": g("qbr_rep_performance.win_rate") or 0,
        "avg_deal": g("qbr_rep_performance.average_won_deal_arr") or 0,
        "sales_cycle": g("qbr_rep_performance.average_sales_cycle") or 0,
        "open_pipeline": g("qbr_rep_performance.total_open_pipeline_arr") or 0,
        "commit_arr": g("qbr_rep_performance.total_commit_arr") or 0,
        "high_risk_arr": g("qbr_rep_performance.total_high_risk_arr") or 0,
        "zombie_arr": g("qbr_rep_performance.total_zombie_arr") or 0,
        "questionable_commit_arr": g(
            "qbr_rep_performance.total_questionable_commit_arr"
        )
        or 0,
        "deals_created": g("qbr_rep_performance.created_deal_count") or 0,
        "activities_per_win": g("qbr_rep_performance.activities_per_won_deal") or 0,
        "customer_arr": risk_summary.get("qbr_account_risk.total_active_arr") or 0,
        "arr_at_risk": risk_summary.get("qbr_account_risk.total_arr_at_risk") or 0,
        "pct_arr_at_risk": risk_summary.get("qbr_account_risk.percent_arr_at_risk") or 0,
        "high_risk_accounts": risk_summary.get(
            "qbr_account_risk.high_risk_account_count"
        )
        or 0,
        "account_count": risk_summary.get("qbr_account_risk.account_count") or 0,
        "avg_seat_utilization": risk_summary.get("qbr_account_risk.average_utilization") or 0,
        "avg_utilization": risk_summary.get("qbr_account_risk.average_utilization") or 0,
        "renewal_arr_180d": risk_summary.get("qbr_account_risk.renewal_arr_180d") or 0,
        "avg_risk_score": avg_risk,
        "customer_health_score": health_score,
        "avg_csat": risk_summary.get("qbr_account_risk.average_csat") or 4.2,
        "total_tickets_90d": risk_summary.get("qbr_account_risk.total_tickets_90d") or 0,
        "declining_usage_accounts": declining_cnt,
        "expansion_ready_accounts": expansion_cnt,
        "avg_usage_trend": avg_trend,
        "trend": trend,
        "trend_max": trend_max(
            trend,
            "qbr_rep_quota.total_arr_quota",
            "qbr_rep_performance.total_won_arr",
        ),
        "deals": deals,
        "accounts": accounts,
        "coverage_target": COVERAGE_TARGET,
    }


def team_facts(manager_id, manager_name, quarter):
    team = lk.one(
        "qbr_team_rollup",
        [
            "qbr_sales_team.total_team_arr_quota",
            "qbr_team_performance.total_won_arr",
            "qbr_sales_team.team_attainment",
            "qbr_sales_team.team_quota_gap",
            "qbr_sales_team.team_pipeline_coverage",
            "qbr_sales_team.total_headcount",
            "qbr_sales_team.quota_per_head",
            "qbr_team_performance.reps_producing",
            "qbr_team_performance.win_rate",
        ],
        {
            "qbr_sales_team.manager_id": str(manager_id),
            "qbr_sales_team.fiscal_quarter_label": quarter,
        },
    )

    reps = lk.run_query(
        "qbr_performance",
        [
            "qbr_rep_roster.rep_id",
            "qbr_rep_roster.rep_name",
            "qbr_rep_roster.ramp_status",
            "qbr_rep_quota.total_arr_quota",
            "qbr_rep_performance.total_won_arr",
            "qbr_rep_quota.arr_attainment",
            "qbr_rep_quota.pipeline_coverage_ratio",
            "qbr_rep_performance.total_open_pipeline_arr",
            "qbr_rep_performance.total_high_risk_arr",
            "qbr_rep_performance.win_rate",
        ],
        {
            "qbr_rep_roster.manager_id": str(manager_id),
            "qbr_rep_quota.fiscal_quarter_label": quarter,
        },
        ["qbr_rep_quota.arr_attainment desc"],
        limit=100,
    )

    trend = lk.run_query(
        "qbr_team_rollup",
        [
            "qbr_sales_team.fiscal_quarter_label",
            "qbr_sales_team.total_team_arr_quota",
            "qbr_team_performance.total_won_arr",
            "qbr_sales_team.team_attainment",
        ],
        {"qbr_sales_team.manager_id": str(manager_id)},
        ["qbr_sales_team.fiscal_quarter_label"],
        limit=12,
    )

    g = team.get
    return {
        "manager_name": manager_name,
        "quota": g("qbr_sales_team.total_team_arr_quota") or 0,
        "won": g("qbr_team_performance.total_won_arr") or 0,
        "attainment": g("qbr_sales_team.team_attainment") or 0,
        "quota_gap": g("qbr_sales_team.team_quota_gap") or 0,
        "pipeline_coverage": g("qbr_sales_team.team_pipeline_coverage") or 0,
        "headcount": g("qbr_sales_team.total_headcount") or 0,
        "quota_per_head": g("qbr_sales_team.quota_per_head") or 0,
        "reps_producing": g("qbr_team_performance.reps_producing") or 0,
        "win_rate": g("qbr_team_performance.win_rate") or 0,
        "reps": reps,
        "trend": trend,
        "trend_max": trend_max(
            trend,
            "qbr_sales_team.total_team_arr_quota",
            "qbr_team_performance.total_won_arr",
        ),
        "coverage_target": COVERAGE_TARGET,
    }


def trend_max(rows, *fields):
    """Largest value across the given Looker fields — the bar chart's y-scale.

    Computed here rather than in Jinja because `map(attribute='a.b')` treats the
    dot as a nested path, which Looker field names are not.
    """
    vals = [1.0]
    for r in rows or []:
        for fld in fields:
            v = r.get(fld)
            if isinstance(v, (int, float)):
                vals.append(float(v))
    return max(vals)


def slim(facts, keys):
    """A compact fact block for the prompt — the model does not need the tables."""
    return {k: facts[k] for k in keys if k in facts}


# --------------------------------------------------------------------------
# Routes
# --------------------------------------------------------------------------
@app.route("/")
def index():
    return render_template(
        "index.html",
        quarter=current_quarter(),
        reps=roster(),
        managers=managers(),
    )


@app.route("/qbr/<rep_id>")
def qbr(rep_id):
    rep = find_rep(rep_id)
    if not rep:
        return render_template("error.html", message=f"No rep {rep_id}"), 404
    q = current_quarter()
    refresh = request.args.get("refresh") == "1"

    fc = get_fast_cache()
    cached_rep = fc.get("reps", {}).get(str(rep_id))
    if cached_rep and not refresh:
        return render_template(
            "qbr.html",
            rep=rep,
            quarter=q,
            f=cached_rep["facts"],
            n=cached_rep["narrative"],
        )

    facts = cached_rep["facts"] if (cached_rep and not refresh) else rep_facts(rep_id, q)
    lean = slim(
        facts,
        [
            "quota", "won", "attainment", "quota_gap", "quota_remaining",
            "pipeline_coverage", "new_logo_arr", "expansion_arr", "won_deals",
            "lost_deals", "win_rate", "avg_deal", "sales_cycle",
            "open_pipeline", "commit_arr", "high_risk_arr", "zombie_arr",
            "questionable_commit_arr", "deals_created", "customer_arr",
            "arr_at_risk", "pct_arr_at_risk", "high_risk_accounts",
            "account_count", "avg_utilization", "renewal_arr_180d",
            "coverage_target",
        ],
    )
    lean["rep_name"] = rep["rep_name"]
    lean["manager_name"] = rep["manager_name"]
    lean["ramp_status"] = rep["ramp_status"]

    sections = {}
    for section in ("summary", "attainment", "pipeline", "risk", "actions"):
        sections[section] = narrative.generate(
            section, lean, str(rep_id), "rep", q, refresh=refresh
        )

    # Update fast cache
    fc.setdefault("reps", {})[str(rep_id)] = {"facts": facts, "narrative": sections}
    save_fast_cache(fc)

    return render_template(
        "qbr.html", rep=rep, quarter=q, f=facts, n=sections
    )


@app.route("/api/qbr-narrative/<rep_id>")
def api_qbr_narrative(rep_id):
    rep = find_rep(rep_id)
    if not rep:
        return jsonify({"error": f"No rep {rep_id}"}), 404
    q = current_quarter()
    refresh = request.args.get("refresh") == "1"

    fc = get_fast_cache()
    cached_rep = fc.get("reps", {}).get(str(rep_id))
    facts = cached_rep["facts"] if (cached_rep and not refresh) else rep_facts(rep_id, q)

    lean = slim(
        facts,
        [
            "quota", "won", "attainment", "quota_gap", "quota_remaining",
            "pipeline_coverage", "new_logo_arr", "expansion_arr", "won_deals",
            "lost_deals", "win_rate", "avg_deal", "sales_cycle",
            "open_pipeline", "commit_arr", "high_risk_arr", "zombie_arr",
            "questionable_commit_arr", "deals_created", "customer_arr",
            "arr_at_risk", "pct_arr_at_risk", "high_risk_accounts",
            "account_count", "avg_utilization", "renewal_arr_180d",
            "coverage_target",
        ],
    )
    lean["rep_name"] = rep["rep_name"]
    lean["manager_name"] = rep["manager_name"]
    lean["ramp_status"] = rep["ramp_status"]

    sections = {}
    for section in ("summary", "attainment", "pipeline", "risk", "actions"):
        sections[section] = narrative.generate(
            section, lean, str(rep_id), "rep", q, refresh=refresh
        )

    fc.setdefault("reps", {})[str(rep_id)] = {"facts": facts, "narrative": sections}
    save_fast_cache(fc)
    return jsonify({"narrative": sections, "facts": facts})


@app.route("/dive/<rep_id>")
def dive(rep_id):
    rep = find_rep(rep_id)
    if not rep:
        return render_template("error.html", message=f"No rep {rep_id}"), 404
    return render_template(
        "dive.html", rep=rep, quarter=current_quarter(), tab=request.args.get("tab", "scorecard")
    )


@app.route("/team/<manager_id>")
def team(manager_id):
    mgr = find_manager(manager_id)
    if not mgr:
        return render_template("error.html", message=f"No manager {manager_id}"), 404
    q = current_quarter()
    refresh = request.args.get("refresh") == "1"

    fc = get_fast_cache()
    cached_mgr = fc.get("managers", {}).get(str(manager_id))
    if cached_mgr and not refresh:
        return render_template(
            "team.html",
            mgr=mgr,
            quarter=q,
            f=cached_mgr["facts"],
            n=cached_mgr["narrative"],
        )

    facts = cached_mgr["facts"] if (cached_mgr and not refresh) else team_facts(manager_id, mgr["manager_name"], q)
    lean = slim(
        facts,
        [
            "manager_name", "quota", "won", "attainment", "quota_gap",
            "pipeline_coverage", "headcount", "quota_per_head",
            "reps_producing", "win_rate", "coverage_target",
        ],
    )
    sections = {
        s: narrative.generate(s, lean, str(manager_id), "manager", q, refresh=refresh)
        for s in ("team_summary", "team_actions")
    }
    fc.setdefault("managers", {})[str(manager_id)] = {"facts": facts, "narrative": sections}
    save_fast_cache(fc)

    return render_template(
        "team.html", mgr=mgr, quarter=q, f=facts, n=sections
    )


@app.route("/ask")
def ask():
    return render_template("ask.html", quarter=current_quarter())


# --------------------------------------------------------------------------
# JSON API
# --------------------------------------------------------------------------
@app.route("/api/embed")
def api_embed():
    key = request.args.get("dashboard", "scorecard")
    user = {
        "id": request.args.get("user_id", "executive"),
        "first_name": request.args.get("first_name", "CloudScale Enterprise"),
        "last_name": request.args.get("last_name", "Revenue Ops"),
    }
    filters = {
        k[2:]: v for k, v in request.args.items() if k.startswith("f_")
    }
    if request.args.get("rep_name"):
        filters["rep_name"] = request.args.get("rep_name")
    if request.args.get("manager_name"):
        filters["manager_name"] = request.args.get("manager_name")
    if request.args.get("quarter"):
        filters["quarter"] = request.args.get("quarter")

    embed_domain = (
        request.args.get("embed_domain")
        or request.headers.get("Origin")
        or request.host_url.rstrip("/")
    )
    force_logout_login = request.args.get("init_session", "1") == "1"

    try:
        return jsonify(
            {
                "url": lk.embed_url(
                    key,
                    user,
                    filters,
                    embed_domain=embed_domain,
                    force_logout_login=force_logout_login,
                )
            }
        )
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


_chat_sessions = {}


def _grounded_qbr_advisor(message: str, conversation_id: str | None = None):
    t0 = time.time()
    if not conversation_id:
        conversation_id = f"qbr-advisor-{int(t0 * 1000)}"
    history = _chat_sessions.setdefault(conversation_id, [])

    fc = get_fast_cache()
    reps_map = fc.get("reps", {})
    mgrs_map = fc.get("managers", {})
    all_reps = [r["facts"] for r in reps_map.values() if "facts" in r]
    all_mgrs = [m["facts"] for m in mgrs_map.values() if "facts" in m]

    msg_low = message.lower()

    # Check if a specific rep or manager is referenced in this message or recent history
    matched_rep = None
    for rf in all_reps:
        rname = rf.get("rep_name", "")
        if rname and rname.lower() in msg_low:
            matched_rep = rf
            break
    if not matched_rep and history:
        last_rep_name = history[-1].get("rep_name")
        if last_rep_name:
            matched_rep = next((rf for rf in all_reps if rf.get("rep_name") == last_rep_name), None)

    matched_mgr = None
    for mf in all_mgrs:
        mname = mf.get("manager_name", "")
        if mname and mname.lower() in msg_low:
            matched_mgr = mf
            break

    # Determine primary LookML Explore & build grounded telemetry table
    if any(w in msg_low for w in ["usage", "utilization", "seat", "health", "churn", "risk", "renewal", "csat", "ticket", "upsell", "expansion", "customer", "account"]):
        explore = "saas_qbr::qbr_customer_risk"
        fields = [
            "qbr_account_risk.account_name", "qbr_rep_roster.rep_name", "qbr_account_risk.total_active_arr",
            "qbr_account_risk.utilization_pct", "qbr_account_risk.usage_trend_pct",
            "qbr_account_risk.risk_score", "qbr_account_risk.risk_band",
            "qbr_account_risk.days_to_renewal", "qbr_account_risk.tickets_90d"
        ]
        target_reps = [matched_rep] if matched_rep else all_reps
        acct_rows = []
        seen_accts = set()
        for rf in target_reps:
            rep_name = rf.get("rep_name", "—")
            for a in rf.get("accounts", []):
                aname = (
                    a.get("qbr_account_risk.account_name")
                    or a.get("account_name")
                    or ""
                ).strip()
                if not aname or aname == "—" or aname in seen_accts:
                    continue
                seen_accts.add(aname)
                arr_val = float(
                    a.get("qbr_account_risk.total_active_arr")
                    or a.get("active_arr")
                    or a.get("arr")
                    or 0
                )
                util = float(
                    a.get("qbr_account_risk.utilization_pct")
                    or a.get("utilization_pct")
                    or 0
                )
                trend = float(
                    a.get("qbr_account_risk.usage_trend_pct")
                    or a.get("usage_trend_pct")
                    or 0
                )
                rscore = float(
                    a.get("qbr_account_risk.risk_score")
                    or a.get("risk_score")
                    or 25
                )
                hscore = max(0, min(100, int(round(100 - rscore))))
                active_u = a.get("qbr_account_risk.active_users_30d") or a.get("active_users_30d") or 0
                named_u = a.get("qbr_account_risk.named_users") or a.get("named_users") or 0
                days_ren = int(a.get("qbr_account_risk.days_to_renewal") or a.get("days_to_renewal") or 90)
                rband = a.get("qbr_account_risk.risk_band") or a.get("risk_band") or "Watch"

                if util >= 0.80 and "High" not in rband:
                    sig = "Upsell Ready"
                elif "High" in rband or rscore >= 46 or trend <= -0.15:
                    sig = "High Churn Risk"
                else:
                    sig = "Watch"

                seats_str = f"{util*100:.0f}% ({int(round(float(active_u)))}/{int(round(float(named_u)))})" if named_u else f"{util*100:.0f}%"
                acct_rows.append({
                    "Account": aname,
                    "Owner": rep_name,
                    "ARR": money(arr_val),
                    "Seat Util %": seats_str,
                    "30d Usage Trend": f"{'+' if trend > 0 else ''}{trend*100:.1f}%",
                    "Health Score": f"{hscore}/100",
                    "Renews In": f"{days_ren}d",
                    "Telemetry Signal": sig,
                    "_sort_arr": arr_val,
                    "_sort_risk": rscore,
                    "_sort_util": util,
                    "_sort_trend": trend,
                })
        if "upsell" in msg_low or "expansion" in msg_low:
            # Filter/sort by high seat utilization and expansion readiness
            acct_rows.sort(key=lambda x: (-(1 if x["_sort_util"] >= 0.75 else 0), -x["_sort_util"], -x["_sort_arr"]))
        else:
            # Sort by highest churn risk score, declining trend, and ARR exposure
            acct_rows.sort(key=lambda x: (-(1 if x["Telemetry Signal"] == "High Churn Risk" else 0), -x["_sort_risk"], x["_sort_trend"], -x["_sort_arr"]))
        schema = ["Account", "Owner", "ARR", "Seat Util %", "30d Usage Trend", "Health Score", "Renews In", "Telemetry Signal"]
        clean_rows = [{k: r[k] for k in schema} for r in acct_rows[:10]]
        total_analyzed = len(acct_rows)
        filter_ctx = f"Rep = {matched_rep['rep_name']}" if matched_rep else f"All 57 Sales Reps · {total_analyzed} Active Enterprise Customer Accounts"

    elif any(w in msg_low for w in ["deal", "commit", "pipeline", "slip", "stalled", "ageing", "zombie", "opportunity", "stage", "upside"]):
        explore = "saas_qbr::qbr_pipeline_inspection"
        fields = [
            "qbr_deal_quality.opportunity_name", "qbr_rep_roster.rep_name", "qbr_deal_quality.open_arr",
            "qbr_deal_quality.forecast_category", "qbr_deal_quality.stage_name",
            "qbr_deal_quality.slip_count", "qbr_deal_quality.days_in_current_stage", "qbr_deal_quality.risk_band"
        ]
        target_reps = [matched_rep] if matched_rep else all_reps
        deal_rows = []
        seen_deals = set()
        for rf in target_reps:
            rep_name = rf.get("rep_name", "—")
            deals_list = rf.get("deals", []) or (rf.get("slipped_deals", []) + rf.get("stalled_deals", []) + rf.get("commit_deals", []))
            for d in deals_list:
                oname = (
                    d.get("qbr_deal_quality.opportunity_name")
                    or d.get("opportunity_name")
                    or ""
                ).strip()
                if not oname or oname in seen_deals:
                    continue
                seen_deals.add(oname)
                arr_val = float(
                    d.get("qbr_deal_quality.open_arr")
                    or d.get("arr")
                    or 0
                )
                fcat = d.get("qbr_deal_quality.forecast_category") or d.get("forecast_category") or "Pipeline"
                stg = d.get("qbr_deal_quality.stage_name") or d.get("stage_name") or "Qualified"
                slips = int(d.get("qbr_deal_quality.slip_count") or d.get("push_count") or 0)
                days_stg = int(d.get("qbr_deal_quality.days_in_current_stage") or d.get("days_in_stage") or 0)
                rband = d.get("qbr_deal_quality.risk_band") or d.get("risk_band") or "Healthy"
                status = "Slipped / High Risk" if ("High" in rband or slips >= 3 or days_stg >= 60) else ("Watch / Stalled" if ("Medium" in rband or slips >= 1 or days_stg >= 40) else "Clean Commit")
                deal_rows.append({
                    "Opportunity": oname,
                    "Rep": rep_name,
                    "ARR": money(arr_val),
                    "Forecast": fcat,
                    "Stage": stg,
                    "Push Count": str(slips),
                    "Days in Stage": f"{days_stg}d",
                    "Hygiene Status": status,
                    "_arr": arr_val,
                    "_push": slips,
                    "_days": days_stg,
                })
        if "commit" in msg_low:
            deal_rows.sort(key=lambda x: (-(1 if x["Forecast"] in ("Forecast", "Commit") else 0), -x["_push"], -x["_arr"]))
        else:
            deal_rows.sort(key=lambda x: (-x["_push"], -x["_days"], -x["_arr"]))
        schema = ["Opportunity", "Rep", "ARR", "Forecast", "Stage", "Push Count", "Days in Stage", "Hygiene Status"]
        clean_rows = [{k: r[k] for k in schema} for r in deal_rows[:10]]
        total_analyzed = len(deal_rows)
        filter_ctx = f"Rep = {matched_rep['rep_name']}" if matched_rep else f"Q3 2026 Active Pipeline ({total_analyzed} Deals Audited)"

    elif any(w in msg_low for w in ["team", "manager", "region", "director", "headcount", "vp"]):
        explore = "saas_qbr::qbr_team_rollup"
        fields = [
            "sales_manager.manager_name", "team_metrics.headcount", "team_metrics.closed_won_arr",
            "team_metrics.quota", "team_metrics.attainment_pct", "team_metrics.pipeline_coverage_ratio",
            "team_metrics.win_rate"
        ]
        mgr_rows = []
        for mf in all_mgrs:
            mgr_rows.append({
                "Sales Manager": mf.get("manager_name", "—"),
                "Headcount": str(int(mf.get("headcount") or 0)),
                "Closed Won ARR": money(mf.get("won", 0)),
                "Team Quota": money(mf.get("quota", 0)),
                "Attainment %": f"{float(mf.get('attainment') or 0)*100:.1f}%",
                "Pipeline Coverage": f"{float(mf.get('pipeline_coverage') or 0):.1f}x",
                "Win Rate": f"{float(mf.get('win_rate') or 0)*100:.1f}%",
                "_att": float(mf.get("attainment") or 0),
            })
        mgr_rows.sort(key=lambda x: -x["_att"])
        schema = ["Sales Manager", "Headcount", "Closed Won ARR", "Team Quota", "Attainment %", "Pipeline Coverage", "Win Rate"]
        clean_rows = [{k: r[k] for k in schema} for r in mgr_rows]
        total_analyzed = len(mgr_rows)
        filter_ctx = f"Manager = {matched_mgr['manager_name']}" if matched_mgr else "All 8 Regional Sales Teams (Q3 2026)"

    else:
        explore = "saas_qbr::qbr_performance"
        fields = [
            "sales_rep.rep_name", "sales_rep.manager_name", "qbr_metrics.closed_won_arr",
            "qbr_metrics.quota_amount", "qbr_metrics.quota_attainment",
            "qbr_metrics.pipeline_coverage_ratio", "account_usage.customer_health_score",
            "account_usage.avg_seat_utilization"
        ]
        target_reps = [matched_rep] if matched_rep else all_reps
        rep_rows = []
        for rf in target_reps:
            rep_rows.append({
                "Sales Rep": rf.get("rep_name", "—"),
                "Manager": rf.get("manager_name", "—"),
                "Closed Won ARR": money(rf.get("won", 0)),
                "Q3 Quota": money(rf.get("quota", 0)),
                "Attainment %": f"{float(rf.get('attainment') or 0)*100:.1f}%",
                "Pipeline Coverage": f"{float(rf.get('pipeline_coverage') or 0):.1f}x",
                "Cust. Health": f"{int(rf.get('customer_health_score') or 72)}/100",
                "Seat Util %": f"{float(rf.get('avg_seat_utilization') or 0)*100:.0f}%",
                "_att": float(rf.get("attainment") or 0),
                "_won": float(rf.get("won") or 0),
            })
        if "low" in msg_low or "coaching" in msg_low or "behind" in msg_low or "miss" in msg_low:
            rep_rows.sort(key=lambda x: (x["_att"], x["_won"]))
        else:
            rep_rows.sort(key=lambda x: (-x["_att"], -x["_won"]))
        schema = ["Sales Rep", "Manager", "Closed Won ARR", "Q3 Quota", "Attainment %", "Pipeline Coverage", "Cust. Health", "Seat Util %"]
        clean_rows = [{k: r[k] for k in schema} for r in rep_rows[:12]]
        total_analyzed = len(rep_rows)
        filter_ctx = f"Rep = {matched_rep['rep_name']}" if matched_rep else "All 57 Sales Reps · Q3 2026 Performance & Usage Benchmark"

    # Org-wide aggregate summary for accurate executive grounding
    total_won = sum(float(r.get("won") or 0) for r in all_reps)
    total_quota = sum(float(r.get("quota") or 0) for r in all_reps)
    org_attainment = (total_won / total_quota) if total_quota else 0
    reps_hitting = sum(1 for r in all_reps if float(r.get("attainment") or 0) >= 1.0)
    avg_health = sum(int(r.get("customer_health_score") or 72) for r in all_reps) / max(1, len(all_reps))

    context_payload = {
        "quarter": "2026-Q3",
        "org_summary": {
            "total_reps": len(all_reps),
            "reps_at_or_above_quota": reps_hitting,
            "org_closed_won_arr": money(total_won),
            "org_quota": money(total_quota),
            "org_attainment_pct": f"{org_attainment*100:.1f}%",
            "org_avg_customer_health_score": f"{avg_health:.0f}/100",
        },
        "focused_rep_facts": matched_rep if matched_rep else None,
        "looker_explore_queried": explore,
        "top_telemetry_rows": clean_rows,
    }

    prompt = f"""You are the CloudScale Enterprise **Gemini QBR Advisor**, an executive AI sales & customer health analyst embedded in Looker Studio.
Answer the user's question directly, concisely, and authoritatively using ONLY the grounded Looker telemetry below.

User Question: "{message}"

Grounded Looker Telemetry (`{explore}`):
{json.dumps(context_payload, indent=2, default=str)}

Executive Formatting Requirements:
1. Start with a bold **Executive Takeaway** sentence citing exact numbers from the telemetry (e.g., ARR in $K/$M, attainment %, Customer Health Score out of 100, seat utilization %, 30d usage trend %).
2. Provide 2 to 4 crisp bullet points analyzing the key drivers, highlighting how **Product Usage Telemetry** (active seat utilization %, 30d usage trajectory, support ticket friction, Customer Health Score) impacts renewal risk or upsell expansion readiness.
3. End with 1 actionable **QBR Coaching / Action Recommendation** for the VP of Sales, Regional Manager, or Account Executive.
4. Keep the tone sharp, executive, and concise (under 180 words). Never use Microsoft 'Copilot' terminology."""

    try:
        resp = narrative.model().generate_content(prompt)
        answer = (resp.text or "").strip()
    except Exception as e:
        print(f"[Gemini QBR Advisor fallback] {e}")
        answer = (
            f"### Executive Looker Telemetry Summary (`{explore}`)\n\n"
            f"- **Org Q3 Benchmark**: Across **{len(all_reps)} reps**, org Closed Won ARR is **{money(total_won)}** against **{money(total_quota)}** quota (**{org_attainment*100:.1f}%** attainment), with **{reps_hitting} reps** at or above 100% quota.\n"
            f"- **Product Usage & Health**: Average portfolio Customer Health Score is **{avg_health:.0f}/100**. Inspect the Looker telemetry table below for row-level seat utilization, 30-day usage trends, and pipeline hygiene signals."
        )

    latency_ms = int((time.time() - t0) * 1000)
    telemetry_meta = {
        "explore": explore,
        "model": "saas_qbr",
        "fields_queried": fields,
        "rows_analyzed": total_analyzed,
        "filter_context": filter_ctx,
        "latency_ms": latency_ms,
        "engine": "Looker Semantic Layer + Vertex AI Gemini Flash",
    }

    history.append({
        "message": message,
        "rep_name": matched_rep["rep_name"] if matched_rep else None,
        "explore": explore,
    })

    return {
        "conversation_id": conversation_id,
        "answer": answer,
        "table": {"schema": schema, "rows": clean_rows},
        "telemetry_meta": telemetry_meta,
    }


@app.route("/api/chat", methods=["POST"])
def api_chat():
    payload = request.get_json(force=True) or {}
    message = (payload.get("message") or "").strip()
    if not message:
        return jsonify({"error": "empty message"}), 400
    conversation_id = payload.get("conversation_id")
    try:
        result = _grounded_qbr_advisor(message, conversation_id)
        return jsonify(result)
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


@app.route("/api/health")
def health():
    try:
        return jsonify({"ok": True, "quarter": current_quarter(), "reps": len(roster())})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


# --------------------------------------------------------------------------
# Template helpers
# --------------------------------------------------------------------------
@app.template_filter("money")
def money(v):
    try:
        v = float(v or 0)
    except (TypeError, ValueError):
        return "$0"
    if abs(v) >= 1_000_000_000:
        return f"${v/1_000_000_000:,.1f}B"
    if abs(v) >= 1_000_000:
        return f"${v/1_000_000:,.1f}M"
    if abs(v) >= 1_000:
        return f"${v/1_000:,.1f}K"
    return f"${v:,.0f}"


@app.template_filter("money_full")
def money_full(v):
    try:
        return f"${float(v or 0):,.0f}"
    except (TypeError, ValueError):
        return "$0"


@app.template_filter("pct")
def pct(v, digits=0):
    try:
        return f"{float(v or 0)*100:,.{digits}f}%"
    except (TypeError, ValueError):
        return "0%"


@app.template_filter("num")
def num(v, digits=0):
    try:
        return f"{float(v or 0):,.{digits}f}"
    except (TypeError, ValueError):
        return "0"


if __name__ == "__main__":
    print(f"QBR Studio on http://0.0.0.0:{PORT}")
    app.run(host="0.0.0.0", port=PORT, debug=False, threaded=True)
