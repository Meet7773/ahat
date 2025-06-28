<div align="center">

# 🛡️ A.H.A.T. - Automated Hardening & Auditing Toolkit

**Security Automation for Debian-Based Systems**  
Your Linux fortress — hardened, audited, and always watching.

[![Language](https://img.shields.io/badge/Language-Bash-blue.svg)](#)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange.svg)](#)

</div>

---

## ✨ Features

A.H.A.T. is a modular toolkit for **automated hardening**, **security auditing**, and **threat detection**. Designed for **Ubuntu Server** and other Debian-based systems.

### 🔧 Hardening
- 🔐 **Unattended Upgrades** – Automatically applies security patches.
- 🔥 **UFW Firewall** – Configures a secure default-deny policy.
- ⚙️ **Service Management** – Disables unnecessary and risky services.
- 🧠 **Password Policy** – Enforces strong password rules via `PAM`.
- 🛑 **Critical File Lockdown** – Tightens permissions on sensitive files.
- 🛠️ **Security Tools Installation** – Installs and configures `ClamAV`, `auditd`, and `AIDE`.

### 🔎 Auditing
- 📋 **Full System Scan** – Checks compliance against hardening rules.
- 🧾 **Baseline Check** – Verifies services, permissions, and firewall rules.
- 🕵️‍♂️ **Privilege Escalation Scan** – Detects non-root users with UID 0.

### 🚨 Threat Detection & Reporting
- 📄 **Threat Reports** – Generates timestamped summaries of system health.
- 🔍 **File Integrity Monitoring** – Uses AIDE to detect unauthorized changes.
- 🦠 **Malware Scans** – Runs `ClamAV` on user directories.
- 📑 **Auth Log Analysis** – Extracts failed logins, `sudo` usage, and suspicious entries.
- 📆 **Automated Cron Jobs** – Schedules weekly audits and daily scans.

---

## 🖥️ Interactive CLI Menu

```bash
=================================================
  A.H.A.T. - Automated Hardening & Auditing Toolkit
=================================================
  Log file for this session: log/ahat_run_2025-06-28_13-30-53.log

   [H]ardening Modules (Manual)
   [A]uditing Modules (Manual)
   [T]hreat Detection & Reporting
   [S]etup Background Automation (Cron for Audits)
   [Q]uit

Select a menu [H/A/T/S/Q]:
```

---

## 📁 Directory Structure

```
ahat/
├── ahat.sh
├── README.md
├── modules/
│   ├── harden.sh
│   ├── audit.sh
│   └── threat_detection.sh
├── config/
│   ├── services.conf
│   └── permissions.conf
├── automation/
│   ├── weekly_audit.sh
│   └── daily_threat_scan.sh
└── log/
    ├── ahat_run_*.log
    ├── weekly_audit.log
    └── threat_report_*.log
```

---

## ✅ Requirements

- 🐧 **OS:** Debian-based system (e.g., Ubuntu Server 22.04+)
- 🔐 **Access:** Root or `sudo` privileges
- 🛠️ **Tools Installed:** `bash`, `ufw`, `clamav`, `auditd`, `aide`

---

## 🚀 Installation

1. **Clone the Repo**

```bash
git clone https://github.com/yourusername/ahat.git
cd ahat
```

2. **Make It Executable**

```bash
chmod +x ahat.sh
```

3. **Run the Toolkit**

```bash
sudo ./ahat.sh
```

4. **Initial Setup**
> Run "Apply ALL Hardening Modules" first to ensure all tools are installed.

---

## 🧾 Logging & Reports

- 🗒️ **Session Logs:** `log/ahat_run_*.log`
- 🛡️ **Threat Reports:** `log/threat_report_*.log`
- 📆 **Weekly Audit:** `log/weekly_audit.log`

Use these logs for auditing, forensics, and compliance verification.

---

## ✍️ Author

> **Meet Patel**  
> 👨‍💻 aka `D3sTr0`  
> 🛠️ Cybersecurity Enthusiast | Automation Architect | Linux Tinkerer  

---

## ⚠️ Disclaimer

> A.H.A.T. is an educational tool. It modifies critical system configurations and installs security components.  
> **Test on a virtual machine** or **non-production system** first.  
> The author is not responsible for any system damage, instability, or data loss.

---

<div align="center">
💀 Stay safe. Stay paranoid. Secure everything. 💀
</div>

