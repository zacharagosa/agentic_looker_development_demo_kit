#!/usr/bin/env python3
"""
scripts/send_gchat_alert.py
Google Chat CardsV2 Alert Dispatcher for NOC & Optical Network Events

Dispatches rich, actionable Google Chat CardsV2 alerts to Google Chat spaces via webhooks.
Designed for closed-loop operations in Looker + BigQuery architectures:
- Can be invoked directly via CLI or automation script.
- Can be called by a Looker Action webhook endpoint when a CE/NOC operator clicks
  "Escalate to NOC Space" on an in-cell LookML dimension.

Zero external pip dependencies (pure Python standard library: urllib.request, json, argparse).

Usage:
  # CLI Dry run test (outputs formatted JSON card without sending HTTP request)
  python3 scripts/send_gchat_alert.py --dry-run

  # Send real alert to webhook
  python3 scripts/send_gchat_alert.py \
    --webhook-url "https://chat.googleapis.com/v1/spaces/.../messages?key=..." \
    --circuit-id "CKT-400G-CHI-DEN-0042" \
    --route "Chicago (ORD-1) ➔ Denver (DEN-2)" \
    --severity "CRITICAL" \
    --rx-power "-28.4 dBm (Threshold: -22.0 dBm)" \
    --sla-risk "$28,500/hr" \
    --impact "3 Tier-1 Cloud Interconnects, 14 Enterprise IP-VPNs" \
    --dashboard-url "https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/dashboards/169"
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone

# Severity configuration mappings (Icon, color indicator, title prefix)
SEVERITY_CONFIG = {
    "CRITICAL": {
        "badge": "🚨 CRITICAL OUTAGE RISK",
        "icon": "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/warning/default/48px.png",
        "header_color": "#D93025",
    },
    "WARNING": {
        "badge": "⚠️ OPTICAL DEGRADATION",
        "icon": "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/error/default/48px.png",
        "header_color": "#F2994A",
    },
    "INFO": {
        "badge": "ℹ️ NETWORK EVENT",
        "icon": "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/info/default/48px.png",
        "header_color": "#1A73E8",
    },
}

def build_card_payload(circuit_id: str,
                       route: str,
                       severity: str,
                       rx_power: str,
                       sla_risk: str,
                       impact: str,
                       dashboard_url: str,
                       incident_id: str = None) -> dict:
    """Constructs a rich Google Chat CardsV2 message payload."""
    sev = severity.upper()
    cfg = SEVERITY_CONFIG.get(sev, SEVERITY_CONFIG["WARNING"])
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    inc_str = f" | Incident: {incident_id}" if incident_id else ""

    buttons = []
    if dashboard_url:
        buttons.append({
            "text": "📊 View in Looker NOC Dashboard",
            "onClick": {
                "openLink": {
                    "url": dashboard_url
                }
            }
        })
    
    # Secondary acknowledge button linking to Looker or NOC portal
    ack_url = f"{dashboard_url}?Circuit={circuit_id}" if dashboard_url else "https://looker.com"
    buttons.append({
        "text": "⚡ Drilldown Circuit Telemetry",
        "onClick": {
            "openLink": {
                "url": ack_url
            }
        }
    })

    card_payload = {
        "cardsV2": [
            {
                "cardId": f"noc_alert_{circuit_id}",
                "card": {
                    "header": {
                        "title": f"{cfg['badge']}: {circuit_id}",
                        "subtitle": f"Detected: {ts}{inc_str}"
                    },
                    "sections": [
                        {
                            "header": "Circuit Telemetry & Impact Assessment",
                            "widgets": [
                                {
                                    "decoratedText": {
                                        "topLabel": "Span Route & Segment",
                                        "text": f"<b>{route}</b>",
                                        "startIcon": {"knownIcon": "MAP_PIN"}
                                    }
                                },
                                {
                                    "decoratedText": {
                                        "topLabel": "Optical Rx Attenuation / Loss",
                                        "text": f"<font color=\"{cfg['header_color']}\"><b>{rx_power}</b></font>",
                                        "startIcon": {"knownIcon": "DESCRIPTION"}
                                    }
                                },
                                {
                                    "decoratedText": {
                                        "topLabel": "Contractual SLA Penalty Exposure",
                                        "text": f"<b>{sla_risk}</b> (Active 99.999% SLA)",
                                        "startIcon": {"knownIcon": "DOLLAR"}
                                    }
                                },
                                {
                                    "decoratedText": {
                                        "topLabel": "Downstream Enterprise Impact",
                                        "text": impact,
                                        "startIcon": {"knownIcon": "MEMBERSHIP"}
                                    }
                                }
                            ]
                        },
                        {
                            "widgets": [
                                {
                                    "buttonList": {
                                        "buttons": buttons
                                    }
                                }
                            ]
                        }
                    ]
                }
            }
        ]
    }
    return card_payload

def dispatch_alert(webhook_url: str, payload: dict, dry_run: bool = False) -> bool:
    """Dispatches the card payload to the Google Chat webhook."""
    formatted_json = json.dumps(payload, indent=2)

    if dry_run:
        print("\n" + "=" * 65)
        print(" [DRY-RUN MODE] Google Chat CardsV2 Payload Preview:")
        print("=" * 65)
        print(formatted_json)
        print("=" * 65)
        print("✓ Dry run completed. No network call was made.\n")
        return True

    if not webhook_url:
        print("Error: Webhook URL is missing. Provide --webhook-url or set GCHAT_WEBHOOK_URL.", file=sys.stderr)
        return False

    req_data = formatted_json.encode("utf-8")
    req = urllib.request.Request(
        webhook_url,
        data=req_data,
        headers={"Content-Type": "application/json; charset=UTF-8"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            response_body = response.read().decode("utf-8")
            if status_code in (200, 201):
                print(f"✓ Alert dispatched successfully! HTTP {status_code}")
                return True
            else:
                print(f"⚠️ Google Chat API returned HTTP {status_code}: {response_body}", file=sys.stderr)
                return False
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")
        print(f"❌ Failed to dispatch alert: HTTP {e.code} - {e.reason}\nResponse: {err_body}", file=sys.stderr)
        return False
    except urllib.error.URLError as e:
        print(f"❌ Network connection error: {e.reason}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"❌ Unexpected error while sending webhook: {str(e)}", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(
        description="Dispatch rich Google Chat CardsV2 alerts for NOC optical network events."
    )
    parser.add_argument("--webhook-url", default=os.getenv("GCHAT_WEBHOOK_URL", ""),
                        help="Google Chat Incoming Webhook URL (or set GCHAT_WEBHOOK_URL env var)")
    parser.add_argument("--circuit-id", default="CKT-400G-CHI-DEN-0042",
                        help="Circuit identifier (e.g. CKT-400G-CHI-DEN-0042)")
    parser.add_argument("--route", default="Chicago (ORD-1) ➔ Denver (DEN-2) [Span SP-IL-CO-01]",
                        help="Human-readable span / route description")
    parser.add_argument("--severity", choices=["CRITICAL", "WARNING", "INFO"], default="CRITICAL",
                        help="Alert severity level (CRITICAL, WARNING, INFO)")
    parser.add_argument("--rx-power", default="-28.4 dBm (Warning Threshold: -22.0 dBm)",
                        help="Measured optical Rx power reading and threshold")
    parser.add_argument("--sla-risk", default="$28,500 / hr",
                        help="Estimated financial SLA penalty liability")
    parser.add_argument("--impact", default="3 Tier-1 Cloud Interconnects, 14 Enterprise IP-VPNs",
                        help="Downstream customers/circuits affected")
    parser.add_argument("--incident-id", default="INC-2026-0941",
                        help="Associated NOC incident / ticket ID")
    parser.add_argument("--dashboard-url",
                        default="https://3417a175-fe20-4370-974f-2f2b535340ab.looker.app/dashboards/169",
                        help="Looker Dashboard or Explore URL for one-click drilldown")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print the CardsV2 JSON payload without making an HTTP request")

    args = parser.parse_args()

    payload = build_card_payload(
        circuit_id=args.circuit_id,
        route=args.route,
        severity=args.severity,
        rx_power=args.rx_power,
        sla_risk=args.sla_risk,
        impact=args.impact,
        dashboard_url=args.dashboard_url,
        incident_id=args.incident_id
    )

    success = dispatch_alert(args.webhook_url, payload, dry_run=args.dry_run)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
