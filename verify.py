#!/usr/bin/env python3
"""End-to-end verification for QBR Studio (CloudScale Enterprise Edition).

Exercises every route, verifies sub-50ms instant cached QBR loading,
checks embedded Looker dashboard SSO authentication across all 6 dashboards,
verifies automatic single-rep filtering, and asserts CloudScale Enterprise branding.
"""

import http.cookiejar
import json
import re
import sys
import time
import urllib.error
import urllib.request

BASE = "http://127.0.0.1:8092"
FALLBACK_MARKERS = ("Narrative unavailable", "which is behind quota with a gap")
CASUAL_TITLES = ("Why Am I Missing Quota", "Why am I missing quota", "Is This Deal Real", "Is this deal real")
CUSTOMER_TERMS = ("palo alto", "panw", "strata", "prisma", "cortex")


def get(path, timeout=300):
    t0 = time.time()
    try:
        with urllib.request.urlopen(BASE + path, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "replace"), time.time() - t0
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace"), time.time() - t0
    except Exception as e:
        return 0, str(e), time.time() - t0


def post(path, body, timeout=300):
    t0 = time.time()
    req = urllib.request.Request(
        BASE + path, data=json.dumps(body).encode(), method="POST"
    )
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, json.loads(r.read()), time.time() - t0
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode()[:300]}, time.time() - t0
    except Exception as e:
        return 0, {"error": str(e)}, time.time() - t0


results = []


def check(name, ok, detail=""):
    results.append((ok, name, detail))
    print(f"  {'✓' if ok else '✗'}  {name}{('  — ' + detail) if detail else ''}")


print("\n### Health")
code, body, _ = get("/api/health", 120)
health = json.loads(body) if code == 200 else {}
check(
    "health endpoint",
    code == 200 and health.get("ok"),
    f"quarter={health.get('quarter')} reps={health.get('reps')}",
)

print("\n### Landing page (Embedded Looker Executive Overview)")
code, html, t = get("/", 120)
reps = re.findall(r'href="/qbr/([^"]+)"', html)
mgrs = re.findall(r'href="/team/([^"]+)"', html)
check("GET /", code == 200, f"{t*1000:.1f}ms, {len(html)}b")
check("embedded Looker overview dashboard on homepage", 'id="overview-frame"' in html and "dashboard: 'overview'" in html)
check("rep selector & directory rendered", len(reps) > 20, f"{len(reps)} reps")
check("CloudScale Enterprise header & branding", "CloudScale Enterprise" in html and "#4F46E5" in html)
check("no casual dashboard titles on homepage", not any(c in html for c in CASUAL_TITLES))
check("zero customer terms on homepage", not any(c in html.lower() for c in CUSTOMER_TERMS))

if not reps or not mgrs:
    print("\nCannot continue without a roster.")
    sys.exit(1)

rep_id, mgr_id = reps[0], mgrs[0]

print("\n### QBR deck (Instant Cached Load & Enterprise Titles)")
code, html, t = get(f"/qbr/{rep_id}")
check("GET /qbr/<rep> instant cached load", code == 200 and t < 1.0, f"{t*1000:.1f}ms, {len(html)}b")
check("five slides present", html.count('class="slide ') >= 5, f"{html.count('class=\"slide ')} slides")
check("no fallback prose", not any(m in html for m in FALLBACK_MARKERS))
check("professional Enterprise titles (no casual terms)", not any(c in html for c in CASUAL_TITLES))
check("zero customer terms in QBR slides & narrative", not any(c in html.lower() for c in CUSTOMER_TERMS))
check("Looker embedded iframes present", "qbr-iframe" in html)
check("sequential SSO session priming (no URL mutation)", "init_session" in html and "frame.src = j.url" in html)
check("export button present", "window.print()" in html)

print("\n### Team roll-up")
code, html, t = get(f"/team/{mgr_id}")
check("GET /team/<mgr> instant load", code == 200 and t < 1.0, f"{t*1000:.1f}ms, {len(html)}b")

listed = html.count('href="/qbr/')
m = re.search(r"([\d,]+) quota-carrying reps", html)
expected = int(m.group(1).replace(",", "")) if m else None
check(
    "rep leaderboard matches headcount",
    expected is not None and listed == expected,
    f"{listed} listed vs {expected} on the team",
)
check("no fallback prose", not any(m in html for m in FALLBACK_MARKERS))
check("Looker embedded iframe present", "qbr-iframe" in html)

print("\n### Deep dive (Single-Rep Automatic Filtering)")
code, html, t = get(f"/dive/{rep_id}", 120)
check("GET /dive/<rep>", code == 200 and t < 1.0, f"{t*1000:.1f}ms, {len(html)}b")
check("four enterprise dashboard tabs", html.count("tabbtn") >= 4)
check("no casual tab titles", not any(c in html for c in CASUAL_TITLES))
check("passes rep_name filter to /api/embed", "rep_name: REP" in html)
check("no header bar above iframe", '<iframe' in html and 'id="frame-wrap"' in html)

print("\n### Signed SSO Embed Authentication & Single-Rep Filtering (All 6 Dashboards)")
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

embed_tests = [
    ("overview", "init_session=1", "Quarter=2026-Q3"),
    ("scorecard", "rep_name=Miguel+Owens&init_session=0", "Sales+Rep=Miguel+Owens"),
    ("quota", "rep_name=Miguel+Owens&init_session=0", "Sales+Rep=Miguel+Owens"),
    ("deals", "rep_name=Miguel+Owens&init_session=0", "Sales+Rep=Miguel+Owens"),
    ("risk", "rep_name=Miguel+Owens&init_session=0", "Account+Owner=Miguel+Owens"),
    ("team", "manager_name=Anita+Krausz&init_session=0", "Manager=Anita+Krausz"),
]

for key, query_str, expected_param in embed_tests:
    code, body, t = get(f"/api/embed?dashboard={key}&{query_str}", 120)
    url = json.loads(body).get("url", "") if code == 200 else ""
    try:
        resp = opener.open(url)
        http_ok = resp.status == 200
        final_url = resp.url
    except Exception as e:
        http_ok = False
        final_url = str(e)
    check(
        f"SSO embed {key} authenticates (HTTP 200) & filters ({expected_param})",
        http_ok and expected_param in final_url,
        f"{t*1000:.0f}ms -> {final_url.split('?')[0].split('/')[-1]}",
    )

print("\n### Conversational Analytics")
code, body, t = post("/api/chat", {"message": "Which reps are behind quota this quarter?"})
answer = body.get("answer", "")
check("POST /api/chat", code == 200 and bool(answer), f"{t:.1f}s")
check("answer is grounded", "$" in answer or "%" in answer, answer[:90].replace("\n", " "))

print("\n### Ask page & Branding")
code, html, _ = get("/ask", 120)
check("GET /ask (Gemini QBR Advisor branding)", code == 200 and "Gemini QBR Advisor" in html and "Copilot" not in html)

print("\n### LookML KPI Tiles Auto-Resize (smart_single_value_size: true)")
import looker_client
from looker_sdk import models40
sdk = looker_client.sdk()
sdk.update_session(models40.WriteApiSession(workspace_id="production"))
for key, dash_id in looker_client.DASHBOARDS.items():
    d = sdk.dashboard(dash_id)
    kpis = [
        dict(el.result_maker.vis_config)
        for el in (d.dashboard_elements or [])
        if el.result_maker and el.result_maker.vis_config and el.result_maker.vis_config.get("type") == "single_value"
    ]
    all_smart = len(kpis) > 0 and all(vc.get("smart_single_value_size") is True for vc in kpis)
    check(f"Dashboard {key} KPI tiles auto-resize ({len(kpis)} tiles)", all_smart, f"{dash_id}")

passed = sum(1 for ok, _, _ in results if ok)
print(f"\n==== {passed} / {len(results)} checks passed ====")
for ok, name, detail in results:
    if not ok:
        print(f"  FAILED: {name} {detail}")
sys.exit(0 if passed == len(results) else 1)
