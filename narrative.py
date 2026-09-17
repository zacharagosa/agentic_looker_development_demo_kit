"""Gemini-generated QBR prose, grounded in live Looker query results.

Every narrative is written from numbers this module pulls out of Looker first,
so the model never invents a figure. Results are cached in
`aragosalooker.saas_qbr.qbr_narrative_cache` keyed by
(subject_id, subject_type, fiscal_quarter, section).
"""

import datetime
import json
import os
import threading

from google.cloud import bigquery
from google.oauth2 import service_account
import vertexai
from vertexai.generative_models import GenerationConfig, GenerativeModel

# Load local .env file if present
env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

PROJECT = os.getenv("GCP_PROJECT", "your-gcp-project-id")
LOCATION = os.getenv("VERTEX_LOCATION", "global")
MODEL_NAME = os.getenv("GEMINI_MODEL", "gemini-3.8-flash")
CACHE_TABLE = f"{PROJECT}.saas_qbr.qbr_narrative_cache"

SA_KEY = os.getenv(
    "QBR_SA_KEY", os.path.expanduser("~/.config/gcloud/sa_key.json")
)
SCOPES = ["https://www.googleapis.com/auth/cloud-platform"]

_lock = threading.Lock()
_model = None
_bq = None


def credentials():
    if os.path.exists(SA_KEY):
        return service_account.Credentials.from_service_account_file(
            SA_KEY, scopes=SCOPES
        )
    print(f"[narrative] {SA_KEY} not found — falling back to ADC")
    return None


def model():
    global _model
    with _lock:
        if _model is None:
            vertexai.init(
                project=PROJECT, location=LOCATION, credentials=credentials()
            )
            _model = GenerativeModel(MODEL_NAME)
    return _model


def bq():
    global _bq
    with _lock:
        if _bq is None:
            _bq = bigquery.Client(project=PROJECT, credentials=credentials())
    return _bq


# --------------------------------------------------------------------------
# Cache
# --------------------------------------------------------------------------
def cache_get(subject_id, subject_type, quarter, section):
    try:
        job = bq().query(
            f"""
            SELECT narrative FROM `{CACHE_TABLE}`
            WHERE subject_id = @sid AND subject_type = @stype
              AND fiscal_quarter = @q AND section = @sec
            ORDER BY generated_at DESC LIMIT 1
            """,
            job_config=bigquery.QueryJobConfig(
                query_parameters=[
                    bigquery.ScalarQueryParameter("sid", "STRING", subject_id),
                    bigquery.ScalarQueryParameter("stype", "STRING", subject_type),
                    bigquery.ScalarQueryParameter("q", "STRING", quarter),
                    bigquery.ScalarQueryParameter("sec", "STRING", section),
                ]
            ),
        )
        for row in job.result():
            return row.narrative
    except Exception as e:  # cache is best-effort, never fatal
        print(f"[narrative] cache read skipped: {e}")
    return None


def cache_put(subject_id, subject_type, quarter, section, text):
    try:
        bq().insert_rows_json(
            CACHE_TABLE,
            [
                {
                    "subject_id": subject_id,
                    "subject_type": subject_type,
                    "fiscal_quarter": quarter,
                    "section": section,
                    "narrative": text,
                    "model_name": MODEL_NAME,
                    "generated_at": datetime.datetime.now(
                        datetime.timezone.utc
                    ).isoformat(),
                }
            ],
        )
    except Exception as e:
        print(f"[narrative] cache write skipped: {e}")


# --------------------------------------------------------------------------
# Generation
# --------------------------------------------------------------------------
SYSTEM = """You write the narrative sections of a quarterly business review for a
SaaS sales organisation. You are given a JSON block of figures that were just
queried from Looker. Those figures are the only facts you may use — never invent
a number, a name, a deal or a customer.

Style rules:
- Write for a sales leader who has 30 seconds. Lead with the conclusion.
- 2 to 4 sentences. No preamble, no headings, no bullet lists, no markdown.
- Reproduce the supplied figures character-for-character, but write them as plain text.
  Never wrap a figure in quotation marks — write $44,767, not "$44,767".
- The current quarter is partly elapsed, so describe in-quarter attainment as
  pacing, not as a final miss.
- Be direct about bad news, but always point at the lever that moves it.
- Never use the words "leverage", "synergy", "robust" or "deep dive".
"""

SECTION_PROMPTS = {
    "summary": "Write the executive summary slide for this rep's QBR.",
    "attainment": "Explain how the rep is pacing against quota and why.",
    "pipeline": "Assess whether this rep's pipeline is real and sufficient.",
    "risk": "Assess the churn risk sitting in this rep's book of business.",
    "actions": (
        "Recommend the 3 highest-leverage actions for this rep this quarter. "
        "Write them as three short sentences, not a list."
    ),
    "team_summary": "Write the executive summary for this manager's team QBR.",
    "team_actions": (
        "Recommend the 3 highest-leverage coaching actions for this manager. "
        "Write them as three short sentences, not a list."
    ),
}


MONEY_KEYS = {
    "quota", "won", "quota_gap", "quota_remaining", "new_logo_arr",
    "expansion_arr", "avg_deal", "open_pipeline", "commit_arr",
    "high_risk_arr", "zombie_arr", "questionable_commit_arr", "customer_arr",
    "arr_at_risk", "renewal_arr_180d", "quota_per_head",
}
PCT_KEYS = {
    "attainment", "win_rate", "pct_arr_at_risk", "avg_utilization",
}

# Plain-English labels. Without these the model echoes raw keys into the prose
# ("...to protect the $120,000 arr at risk").
LABELS = {
    "rep_name": "Rep", "manager_name": "Manager", "ramp_status": "Ramp status",
    "quota": "ARR quota", "won": "Closed won ARR",
    "attainment": "Attainment to plan", "quota_gap": "Quota gap",
    "quota_remaining": "Quota remaining",
    "pipeline_coverage": "Pipeline coverage", "coverage_target": "Coverage target",
    "new_logo_arr": "New logo ARR", "expansion_arr": "Expansion ARR",
    "won_deals": "Deals won", "lost_deals": "Deals lost", "win_rate": "Win rate",
    "avg_deal": "Average won deal size", "sales_cycle": "Average sales cycle (days)",
    "open_pipeline": "Open pipeline ARR", "commit_arr": "ARR in commit",
    "high_risk_arr": "High-risk pipeline ARR", "zombie_arr": "Zombie deal ARR",
    "questionable_commit_arr": "Questionable commit ARR",
    "deals_created": "New deals created", "customer_arr": "Customer ARR under management",
    "arr_at_risk": "ARR at churn risk", "pct_arr_at_risk": "Share of book at risk",
    "high_risk_accounts": "High-risk accounts", "account_count": "Accounts in book",
    "avg_utilization": "Average seat utilization",
    "renewal_arr_180d": "ARR renewing within 180 days",
    "headcount": "Team headcount", "quota_per_head": "Quota per head",
    "reps_producing": "Reps who booked revenue",
}


def humanize(facts):
    """Render figures the way we want them quoted back.

    The model reliably echoes strings verbatim but reformats bare numbers, so
    currency and percentages are formatted here rather than trusted to prose.
    """
    out = {}
    for k, v in facts.items():
        label = LABELS.get(k, k.replace("_", " ").capitalize())
        if isinstance(v, (int, float)) and not isinstance(v, bool):
            if k in MONEY_KEYS:
                out[label] = f"${v:,.0f}"
            elif k in PCT_KEYS:
                out[label] = f"{v*100:,.0f}%"
            elif k == "pipeline_coverage":
                out[label] = f"{v:,.1f}x"
            else:
                out[label] = round(v, 2) if isinstance(v, float) else v
        else:
            out[label] = v
    return out


def generate(section, facts, subject_id, subject_type, quarter, refresh=False):
    if not refresh:
        cached = cache_get(subject_id, subject_type, quarter, section)
        if cached:
            return cached

    prompt = (
        f"{SYSTEM}\n\n"
        f"TASK: {SECTION_PROMPTS.get(section, SECTION_PROMPTS['summary'])}\n\n"
        f"FIGURES (from Looker, quarter {quarter}). Currency and percentages are\n"
        f"already formatted — quote them exactly as written:\n"
        f"{json.dumps(humanize(facts), indent=2, default=str)}\n\n"
        f"Respond with the prose only."
    )
    try:
        resp = model().generate_content(
            prompt,
            # gemini-3.8-flash spends output tokens reasoning before it writes,
            # so a tight budget truncates the prose mid-sentence.
            generation_config=GenerationConfig(
                temperature=0.3, max_output_tokens=8192
            ),
        )
        text = (resp.text or "").strip()
    except Exception as e:
        print(f"[narrative] generation failed for {section}: {e}")
        return fallback(section, facts)

    if text:
        cache_put(subject_id, subject_type, quarter, section, text)
    return text or fallback(section, facts)


def fallback(section, facts):
    """Deterministic prose so a Vertex outage never blanks out a QBR deck."""
    att = facts.get("attainment")
    gap = facts.get("quota_gap")
    if section in ("summary", "attainment", "team_summary") and att is not None:
        verb = "ahead of" if att >= 1 else "behind"
        return (
            f"Currently {att:.0%} to plan, which is {verb} quota with a gap of "
            f"{_money(gap)}. Pipeline coverage is "
            f"{facts.get('pipeline_coverage') or 0:.1f}x against a 3.0x standard."
        )
    return "Narrative unavailable — the underlying figures are shown above."


def _money(v):
    try:
        return f"${float(v):,.0f}"
    except (TypeError, ValueError):
        return "$0"
