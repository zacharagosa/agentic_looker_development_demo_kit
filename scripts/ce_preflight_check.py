#!/usr/bin/env python3
"""
Looker CE Demo Environment Readiness & Pre-flight Health Check
Checks if the CE's local workstation, gcloud, BigQuery, Looker Argolis instance,
and looker-cli session are properly configured prior to starting a live customer demo.

Usage:
  python3 scripts/ce_preflight_check.py [--connection-name MY_BQ_CONN] [--looker-host MY_HOST]
"""

import argparse
import json
import os
import shutil
import subprocess
import sys

# Color formatting helpers for terminal output
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
BOLD = "\033[1m"
RESET = "\033[0m"

def log_pass(msg):
    print(f"  [{GREEN}PASS{RESET}] {msg}")

def log_warn(msg):
    print(f"  [{YELLOW}WARN{RESET}] {msg}")

def log_fail(msg):
    print(f"  [{RED}FAIL{RESET}] {msg}")

def run_cmd(cmd_list):
    try:
        res = subprocess.run(cmd_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=15)
        return res.returncode, res.stdout.strip(), res.stderr.strip()
    except Exception as e:
        return 1, "", str(e)

def check_gcloud():
    print(f"\n{BOLD}1. Checking Google Cloud SDK & Authentication:{RESET}")
    gcloud_path = shutil.which("gcloud")
    if not gcloud_path:
        log_fail("`gcloud` CLI is not installed or not in PATH.")
        print(f"     -> Remediation: Install Google Cloud SDK or add gcloud to PATH.")
        return False, None
    log_pass(f"`gcloud` found at: {gcloud_path}")

    # Check auth
    code, stdout, stderr = run_cmd(["gcloud", "auth", "list", "--filter=status:ACTIVE", "--format=value(account)"])
    if code == 0 and stdout:
        log_pass(f"Authenticated GCP Account: {stdout}")
    else:
        log_fail("`gcloud` is not authenticated.")
        print(f"     -> Remediation: Run 'gcloud auth login' in your terminal.")
        return False, None

    # Check default project
    code, stdout, stderr = run_cmd(["gcloud", "config", "get-value", "project"])
    gcp_project = stdout if (code == 0 and stdout and stdout != "(unset)") else None
    if gcp_project:
        log_pass(f"Active GCP Project: {gcp_project}")
    else:
        log_warn("No active GCP default project set in gcloud config.")
        print(f"     -> Remediation: Run 'gcloud config set project YOUR_ARGOLIS_PROJECT_ID'")

    return True, gcp_project

def check_bigquery(gcp_project):
    print(f"\n{BOLD}2. Checking BigQuery CLI & Dataset Permissions:{RESET}")
    bq_path = shutil.which("bq")
    if not bq_path:
        log_fail("`bq` CLI is not installed or not in PATH.")
        print(f"     -> Remediation: Run 'gcloud components install bq'")
        return False
    log_pass(f"`bq` CLI found at: {bq_path}")

    if gcp_project:
        code, stdout, stderr = run_cmd(["bq", "ls", "--project_id", gcp_project])
        if code == 0:
            log_pass(f"Successfully listed BigQuery datasets in project '{gcp_project}'.")
        else:
            log_warn(f"Could not list datasets in project '{gcp_project}': {stderr}")
            print(f"     -> Note: Ensure your GCP user/service account has 'BigQuery Admin' or 'BigQuery Data Editor' role.")
    return True

def check_looker_cli(target_conn=None):
    print(f"\n{BOLD}3. Checking Looker CLI & Argolis Instance Session:{RESET}")
    looker_cli_path = shutil.which("looker-cli")
    if not looker_cli_path:
        # Check ~/.local/bin/looker-cli
        alt_path = os.path.expanduser("~/.local/bin/looker-cli")
        if os.path.exists(alt_path):
            looker_cli_path = alt_path
        else:
            log_fail("`looker-cli` is not installed or not in PATH.")
            print(f"     -> Remediation: Install looker-cli or add ~/.local/bin to your PATH.")
            return False
    log_pass(f"`looker-cli` found at: {looker_cli_path}")

    # Check looker-cli authentication / user me
    code, stdout, stderr = run_cmd([looker_cli_path, "user", "me"])
    if code == 0:
        log_pass("`looker-cli` session is active and authenticated.")
        try:
            user_data = json.loads(stdout)
            user_email = user_data.get("email", "Unknown")
            log_pass(f"Authenticated as Looker User: {user_email}")
        except Exception:
            pass
    else:
        log_fail("`looker-cli` is not authenticated with your Argolis Looker instance.")
        print(f"     -> Remediation: Run 'looker-cli session login --host https://your-instance.looker.com' or set LOOKER_BASE_URL & credentials.")
        return False

    # Check connection list
    code, stdout, stderr = run_cmd([looker_cli_path, "connection", "list"])
    if code == 0:
        try:
            conns = json.loads(stdout)
            conn_names = [c.get("name") for c in conns if isinstance(c, dict) and "name" in c]
            log_pass(f"Found {len(conn_names)} Looker DB Connection(s): {', '.join(conn_names[:5])}")

            if target_conn:
                if target_conn in conn_names:
                    log_pass(f"Target connection '{target_conn}' verified in Argolis Looker!")
                else:
                    log_fail(f"Specified connection '{target_conn}' was not found in Looker connections.")
            else:
                bq_conns = [c for c in conns if c.get("dialect_name") in ["bigquery_standard_sql", "bigquery"]]
                if bq_conns:
                    log_pass(f"Valid BigQuery Connection found: '{bq_conns[0].get('name')}'")
                else:
                    log_warn("No BigQuery connection automatically detected. Ensure a BQ connection exists in Looker.")
        except Exception:
            log_pass("Connection list query succeeded.")
    else:
        log_warn("Could not retrieve Looker connection list via CLI.")

    return True

def check_gchat_webhook(webhook_url=None):
    print(f"\n{BOLD}4. Checking Closed-Loop Google Chat Alerting Integration:{RESET}")
    url = webhook_url or os.getenv("GCHAT_WEBHOOK_URL")
    if not url:
        log_warn("No Google Chat webhook URL specified. Closed-loop alert escalation will run in dry-run mode.")
        print(f"     -> Info: Pass --chat-webhook-url or set GCHAT_WEBHOOK_URL to enable real-time alert dispatch.")
        return True

    if url.startswith("https://chat.googleapis.com/"):
        log_pass("Google Chat incoming webhook endpoint configured and formatted correctly.")
        return True
    else:
        log_warn(f"Webhook URL does not match standard Google Chat endpoint: {url[:30]}...")
        return True

def main():
    parser = argparse.ArgumentParser(description="Looker CE Pre-flight Environment Readiness Check")
    parser.add_argument("--connection-name", help="Specific BigQuery connection name in Looker to check")
    parser.add_argument("--chat-webhook-url", help="Google Chat incoming webhook URL for closed-loop alerting")
    args = parser.parse_args()

    print(f"{BOLD}===================================================={RESET}")
    print(f"{BOLD}   Looker CE Live Demo Environment Readiness Check  {RESET}")
    print(f"{BOLD}===================================================={RESET}")

    gcloud_ok, gcp_project = check_gcloud()
    bq_ok = check_bigquery(gcp_project)
    looker_ok = check_looker_cli(target_conn=args.connection_name)
    chat_ok = check_gchat_webhook(webhook_url=args.chat_webhook_url)

    print(f"\n{BOLD}===================================================={RESET}")
    print(f"{BOLD}                  Readiness Summary                 {RESET}")
    print(f"{BOLD}===================================================={RESET}")

    if gcloud_ok and bq_ok and looker_ok and chat_ok:
        print(f"\n{GREEN}{BOLD}>>> ALL CHECKS PASSED! Your environment is READY for live customer demos. <<<{RESET}\n")
        sys.exit(0)
    else:
        print(f"\n{RED}{BOLD}>>> SOME CHECKS FAILED! Please resolve the remediation items above before your demo. <<<{RESET}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
