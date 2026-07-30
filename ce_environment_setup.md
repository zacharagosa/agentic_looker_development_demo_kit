# Looker CE Agentic Demo Kit: One-Time Environment Setup Guide

Welcome to the **Phase 1 Environment Setup Guide** for Looker Customer Engineers (CEs). Before delivering live, agentic Looker demonstrations with **Jetski**, you need your Cloudtop environment properly configured with authenticated Google Cloud (Argolis) and Looker CLI tools.

This one-time setup typically takes **5–10 minutes**. Once configured, your environment is ready for repeated customer demonstrations.

---

## 🛠️ Setup Overview & Standard Architecture

All Looker CEs use a standardized, single-stack demo environment architecture:

| Component | Standard Platform | Setup Target |
| :--- | :--- | :--- |
| **Development Environment** | **Cloudtop** | Linux workstation running Python 3.10+ and Git |
| **GCP & BigQuery** | **Argolis GCP Project** | `gcloud` & `bq` authenticated with your **Argolis User Account** |
| **Looker Instance & DB Connection** | **Argolis Looker Instance** | Looker Core / Argolis instance with working BigQuery connection |
| **Agentic AI Interface** | **Jetski Web** | Browser-based Jetski web interface for live agentic coding and demo execution |
| **Looker CLI** | `looker-cli` | Installed on Cloudtop, authenticated to Argolis Looker instance |

---

## 0️⃣ Initial Platform Provisioning & Access

Before configuring CLI authentication, ensure you have requested and provisioned access to the 3 core platforms:

### 1. Provisioning Your Cloudtop Workstation
1. Navigate to **[go/cloudtop](http://go/cloudtop)** and request/provision a standard Linux/Debian workstation.
2. Connect to your Cloudtop using SSH or VS Code:
   - **Terminal SSH**:
     ```bash
     ssh <your-ldap>@<your-cloudtop-hostname>.c.googlers.com
     ```
   - **VS Code Remote - SSH**: Install the *Remote - SSH* extension and add `ssh <your-ldap>@<your-cloudtop-hostname>.c.googlers.com`.
3. Open a terminal session on your Cloudtop and verify Python/Git:
   ```bash
   python3 --version   # Should be 3.10+
   git --version
   ```

### 2. Setting Up Your Argolis Environment (Looker Core & BigQuery)
1. Access your Argolis demo portal at **[go/argolis](http://go/argolis)**.
2. Select or request an assigned **Argolis GCP Project** with BigQuery API enabled.
3. Access your Argolis Looker Core instance at **[go/looker-argolis](http://go/looker-argolis)**. Ensure you have admin access and an active BigQuery database connection configured under **Admin -> Connections**.

### 3. Launching Jetski Web
1. Open **Jetski Web** at **[go/jetski](http://go/jetski)** in your local browser.
2. Connect Jetski Web to your Cloudtop workspace directory (`/usr/local/google/home/<ldap>/.../looker-ce-demo-kit`).

---

## 1️⃣ Standard Environment Architecture

Looker CEs conduct agentic development and live demos using the standard Cloudtop + Argolis + Jetski Web stack:

1. **Workstation**: Execute all CLI commands and host script tools on your **Cloudtop**.
2. **Argolis Environment**: Manage your Looker Core instance and BigQuery datasets in your assigned **Argolis GCP project** (`go/argolis`).
3. **Jetski Web Interface**: Run all live customer demos by interacting with the agent (building LookML, running validation queries, and generating dashboards) directly through **Jetski Web in your local browser**.

---

## 2️⃣ Configuring Google Cloud SDK (`gcloud`) & BigQuery (`bq`)

> [!IMPORTANT]
> **Execution Location**: All commands below are run directly inside your **Cloudtop terminal** (via SSH or VS Code Remote SSH).

Your demo scripts and the Jetski agent interact with BigQuery to inspect schemas and create/query datasets in Argolis.

> [!IMPORTANT]
> **Use Your Argolis User Identity**: You **MUST** authenticate `gcloud` using your **Argolis user identity** (e.g. `user@argolis.labs.google` or assigned Argolis credentials), **NOT** your `@google.com` Corp account. This ensures proper IAM permissions for BigQuery dataset creation and project management.

### Step 1: SSH into Your Cloudtop Workstation
If you have not already done so, open your local terminal and SSH into your Cloudtop:

```bash
ssh <your-ldap>@<your-cloudtop-hostname>.c.googlers.com
```

### Step 2: Authenticate `gcloud` on Cloudtop with Your Argolis Account

```bash
# Login to gcloud using your Argolis user identity (NOT @google.com Corp account)
gcloud auth login

# Set Application Default Credentials for local Python SDK & BigQuery tools
gcloud auth application-default login
```

### Step 3: Set Your Active Argolis GCP Project
Set your active project to your assigned Argolis GCP project ID:

```bash
gcloud config set project {your-argolis-project-id}
```

### Step 4: Verify BigQuery Access
Confirm that your Argolis account can query and list BigQuery datasets:

```bash
bq ls --project_id=$(gcloud config get-value project)
```

> [!TIP]
> Ensure your Argolis user account has **BigQuery Data Editor** and **BigQuery User** (or BigQuery Admin) IAM roles on your Argolis project so Jetski can construct tables during live demos.

---

## 3️⃣ Installing & Authenticating Looker CLI (`looker-cli`)

*(Run on your Cloudtop terminal)*

The `looker-cli` enables Jetski to inspect LookML models, validate syntax, and deploy User-Defined Dashboards (UDDs) programmatically.

### Step 1: Check for Existing Installation
On your Cloudtop terminal, check if `looker-cli` is already available in your `PATH`:

```bash
looker-cli --version
```

If it prints a version number, skip to **Step 3**.

### Step 2: Install `looker-cli` on Cloudtop
Download the latest Linux binary:

```bash
curl -L -o looker-cli https://github.com/looker-open-source/looker-cli/releases/latest/download/looker-cli-linux-amd64
chmod +x looker-cli
mkdir -p ~/.local/bin
mv looker-cli ~/.local/bin/looker-cli
export PATH=$PATH:~/.local/bin
```

### Step 3: Configure Your Argolis Looker Instance Profile
Add a profile pointing to your Argolis Looker instance host:

```bash
looker-cli profile add default --host https://your-argolis.looker.com --port 443
looker-cli profile use default
```

### Step 4: Authorize via OAuth Interactive Login
Run the OAuth login command to authenticate your Argolis Looker user session:

```bash
looker-cli session login --oauth
```

1. Copy the URL printed in the terminal (`Opening browser to URL: ...`).
2. Open the URL in your local browser and log in to your Argolis Looker instance.
3. Click **Authorize** to grant CLI access.
4. Verify your authentication status:
   ```bash
   looker-cli me
   ```
   You should see your Argolis Looker user details and active session status.

---

## 4️⃣ Looker Database Connection Verification

Ensure that your Argolis Looker instance has an active database connection pointing to BigQuery:

1. Open your Argolis Looker instance in your browser.
2. Navigate to **Admin** -> **Database** -> **Connections**.
3. Confirm there is a working connection (e.g. `bigquery_demo` or `looker-private-demo`) pointing to your BigQuery project.
4. Click **Test** to confirm query execution succeeds.

> [!NOTE]
> Keep note of your Looker connection name—you will pass it as `--connection-name` during **Phase 2** preflight checks.

---

## 5️⃣ Launching Jetski Web

To conduct live demos:
1. Open **Jetski Web** at **[go/jetski](http://go/jetski)** in your local browser.
2. Ensure Jetski Web is connected to your Cloudtop workspace directory (`looker-ce-demo-kit`).
3. You are ready to interact with Jetski Web live in front of customers to generate schemas, build LookML, validate code, and generate dashboards on the fly!

---

## 📚 Essential Resources & Quick Links for CEs

- **Google Cloudtop Portal**: [go/cloudtop](http://go/cloudtop)
- **Argolis GCP & Looker Environments**: [go/argolis](http://go/argolis) | [go/looker-argolis](http://go/looker-argolis)
- **Looker CLI GitHub Repository**: [github.com/looker-open-source/looker-cli](https://github.com/looker-open-source/looker-cli)
- **Jetski Agent Support & Web UI**: [go/jetski](http://go/jetski)

---

## ✅ Next Steps: Proceed to Phase 2

Once your environment setup is complete, run the automated readiness check script on Cloudtop before any customer meeting:

```bash
python3 scripts/ce_preflight_check.py --connection-name <your_looker_connection_name>
```

Return to [ce_demo_playbook.md](ce_demo_playbook.md) for the 5-phase live demo guide.
