"""Thin wrapper around the Looker SDK for QBR Studio.

Handles three things the app needs from Looker:
  1. running inline queries against the saas_qbr model (for narrative + cards)
  2. minting signed SSO embed URLs for the six LookML dashboards
  3. proxying Conversational Analytics chat to the Gemini QBR Advisor agent
"""

import json
import os
import urllib.parse
import urllib.request
import urllib.error

import looker_sdk
from looker_sdk import models40

# Load local .env file if present
env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

LOOKER_HOST = os.getenv(
    "LOOKER_HOST", "your-instance.looker.app"
)
LOOKER_URI = f"https://{LOOKER_HOST}"
CLIENT_ID = os.getenv("LOOKER_CLIENT_ID", "")
CLIENT_SECRET = os.getenv("LOOKER_CLIENT_SECRET", "")

MODEL = "saas_qbr"
AGENT_ID = os.getenv("QBR_AGENT_ID", "")

DASHBOARDS = {
    "overview": "saas_qbr::executive_sales_overview",
    "scorecard": "saas_qbr::my_qbr_scorecard",
    "team": "saas_qbr::team_qbr_rollup",
    "quota": "saas_qbr::why_am_i_missing_quota",
    "deals": "saas_qbr::is_this_deal_real",
    "risk": "saas_qbr::customer_risk_and_usage",
}

os.environ["LOOKERSDK_BASE_URL"] = LOOKER_URI
os.environ["LOOKERSDK_CLIENT_ID"] = CLIENT_ID
os.environ["LOOKERSDK_CLIENT_SECRET"] = CLIENT_SECRET
os.environ["LOOKERSDK_VERIFY_SSL"] = "true"

_sdk = None


def sdk():
    global _sdk
    if _sdk is None:
        _sdk = looker_sdk.init40()
    return _sdk


# --------------------------------------------------------------------------
# Raw REST helper — used for the Conversational Analytics endpoints, which
# are beta and not yet surfaced on the generated SDK.
# --------------------------------------------------------------------------
_token = None


def _api_token():
    global _token
    if _token:
        return _token
    data = urllib.parse.urlencode(
        {"client_id": CLIENT_ID, "client_secret": CLIENT_SECRET}
    ).encode()
    req = urllib.request.Request(f"{LOOKER_URI}/api/4.0/login", data=data)
    with urllib.request.urlopen(req) as r:
        _token = json.loads(r.read())["access_token"]
    return _token


def rest(method, path, body=None, retry=True):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(
        f"{LOOKER_URI}/api/4.0{path}", data=data, method=method
    )
    req.add_header("Authorization", f"token {_api_token()}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            raw = r.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        if e.code in (401, 403) and retry:
            global _token
            _token = None
            return rest(method, path, body, retry=False)
        raise RuntimeError(f"{method} {path} -> {e.code}: {e.read().decode()[:500]}")


# --------------------------------------------------------------------------
# Queries
# --------------------------------------------------------------------------
def run_query(explore, fields, filters=None, sorts=None, limit=500):
    """Run an inline query and return a list of dicts."""
    body = models40.WriteQuery(
        model=MODEL,
        view=explore,
        fields=fields,
        filters=filters or {},
        sorts=sorts or [],
        limit=str(limit),
    )
    result = sdk().run_inline_query(result_format="json", body=body, cache=True)
    return json.loads(result)


def one(explore, fields, filters=None, sorts=None):
    rows = run_query(explore, fields, filters, sorts, limit=1)
    return rows[0] if rows else {}


# --------------------------------------------------------------------------
# Embedding
# --------------------------------------------------------------------------
def embed_url(dashboard_key, user=None, filters=None, embed_domain=None, force_logout_login=True):
    """Signed SSO embed URL for one of the six QBR LookML dashboards.

    Automatically maps generic rep/manager/quarter filter keys to the exact
    LookML dashboard filter names required by each dashboard so that single-rep
    and single-manager filtering works reliably across all views.
    """
    dash = DASHBOARDS.get(dashboard_key, dashboard_key)
    # CRITICAL: Preserve literal colons in saas_qbr::dashboard_name so Looker
    # does not double-encode %3A%3A -> %253A%253A during /login/embed redirect.
    path = f"/embed/dashboards/{urllib.parse.quote(dash, safe=':')}"

    raw_filters = filters or {}
    rep_val = (
        raw_filters.get("rep_name")
        or raw_filters.get("Sales Rep")
        or raw_filters.get("Account Owner")
        or raw_filters.get("Rep")
        or ""
    )
    mgr_val = raw_filters.get("manager_name") or raw_filters.get("Manager") or ""
    qtr_val = raw_filters.get("quarter") or raw_filters.get("Quarter") or "2026-Q3"

    mapped = {}
    if dashboard_key in ("scorecard", "quota"):
        if rep_val:
            mapped["Sales Rep"] = rep_val
        if qtr_val:
            mapped["Quarter"] = qtr_val
        if mgr_val:
            mapped["Manager"] = mgr_val
    elif dashboard_key == "deals":
        if rep_val:
            mapped["Sales Rep"] = rep_val
        if mgr_val:
            mapped["Manager"] = mgr_val
    elif dashboard_key == "risk":
        if rep_val:
            mapped["Account Owner"] = rep_val
        if mgr_val:
            mapped["Manager"] = mgr_val
    elif dashboard_key == "team":
        if mgr_val:
            mapped["Manager"] = mgr_val
        if qtr_val:
            mapped["Quarter"] = qtr_val
    elif dashboard_key == "overview":
        if qtr_val:
            mapped["Quarter"] = qtr_val
        if mgr_val:
            mapped["Manager"] = mgr_val
    else:
        mapped = {k: v for k, v in raw_filters.items() if v}

    params = {"theme": "Looker"}
    domain = embed_domain or os.getenv("APP_ORIGIN", "")
    if domain:
        params["embed_domain"] = domain
    for k, v in mapped.items():
        if v:
            params[k] = v

    target = f"{LOOKER_URI}{path}?{urllib.parse.urlencode(params)}"

    permissions = [
        "access_data",
        "see_looks",
        "see_user_dashboards",
        "see_lookml_dashboards",
        "explore",
        "save_content",
        "embed_save_shared_space",
        "embed_browse_spaces",
        "see_drill_overlay",
        "schedule_look_emails",
        "download_without_limit",
    ]

    # Use a unified external_user_id across all embeds so concurrent/subsequent
    # iframe loads share the same Looker browser session cookie without clobbering.
    body = models40.EmbedSsoParams(
        target_url=target,
        session_length=86400,
        force_logout_login=bool(force_logout_login),
        external_user_id="qbr_studio_executive",
        first_name="CloudScale Enterprise",
        last_name="Revenue Ops",
        permissions=permissions,
        models=[MODEL, "sfdc_demo"],
        group_ids=[],
        external_group_id="",
        user_attributes={"locale": "en_US"},
    )
    return sdk().create_sso_embed_url(body=body).url


# --------------------------------------------------------------------------
# Conversational Analytics
# --------------------------------------------------------------------------
def ca_new_conversation(name="QBR Studio"):
    r = rest("POST", "/conversations", {"agent_id": AGENT_ID, "name": name})
    return r["id"]


def ca_chat(conversation_id, message):
    """Returns the list of newly generated system messages."""
    return rest(
        "POST",
        "/conversational_analytics/chat",
        {"conversation_id": conversation_id, "user_message": message},
    )


def ca_messages(conversation_id):
    return rest("GET", f"/conversations/{conversation_id}/messages")


def ca_extract(response):
    """Pull the final markdown answer and any data table out of a chat reply."""
    answer, table = "", None
    for entry in response or []:
        msg = entry.get("systemMessage") or {}
        text = msg.get("text") or {}
        if text.get("textType") == "FINAL_RESPONSE":
            answer = "\n".join(text.get("parts") or [])
        data = msg.get("data") or {}
        result = data.get("result") or {}
        if result.get("data"):
            table = {
                "schema": [
                    f.get("name") for f in (result.get("schema") or {}).get("fields", [])
                ],
                "rows": result["data"][:50],
            }
    if not answer:
        for entry in reversed(response or []):
            parts = ((entry.get("systemMessage") or {}).get("text") or {}).get("parts")
            if parts:
                answer = "\n".join(parts)
                break
    return answer, table
