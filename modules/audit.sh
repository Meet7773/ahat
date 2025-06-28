#!/bin/bash

# Auditing Module for A.H.A.T.
# Contains functions to check system compliance.

# --- Helper for PASS/FAIL output ---
print_result() {
    if [ "$1" = "PASS" ]; then
        printf "[PASS]  | %s\n" "$2"
    else
        printf "[FAIL]  | %s\n" "$2"
    fi
}

# --- 1. Audit Automatic Update Configuration ---
# [cite_start]Audits compliance with: Enable automatic updates where possible [cite: 110]
audit_automatic_updates() {
    printf "\n[CHECK] | 1. Auditing Automatic Update Configuration...\n"
    if dpkg -s unattended-upgrades &> /dev/null; then
        print_result "PASS" "Package 'unattended-upgrades' is installed."
    else
        print_result "FAIL" "Package 'unattended-upgrades' is not installed."
        return
    fi
    if grep -q 'APT::Periodic::Unattended-Upgrade "1";' /etc/apt/apt.conf.d/20auto-upgrades; then
        print_result "PASS" "Automatic upgrades are enabled in APT configuration."
    else
        print_result "FAIL" "Automatic upgrades are not enabled in /etc/apt/apt.conf.d/20auto-upgrades."
    fi
}

# --- 2. Audit Firewall Status ---
# [cite_start]Audits compliance with: Configure firewall settings [cite: 112]
audit_firewall_status() {
    printf "\n[CHECK] | 2. Auditing Firewall Status...\n"
    status=$(ufw status | grep -w "Status: active")
    if [ -n "$status" ]; then
        print_result "PASS" "Firewall (UFW) is active."
    else
        print_result "FAIL" "Firewall (UFW) is inactive."
    fi
}

# --- 3. Audit For Unnecessary Services ---
# [cite_start]Audits compliance with: Disable unnecessary services and features [cite: 111]
audit_disabled_services() {
    printf "\n[CHECK] | 3. Auditing for unnecessary services...\n"
    status=$(systemctl is-enabled telnet.socket 2>/dev/null)
    if [ "$status" = "disabled" ] || [ "$status" = "masked" ]; then
        print_result "PASS" "Telnet service is disabled."
    else
        print_result "FAIL" "Telnet service is enabled."
    fi
}

# --- 4. Audit Password Policies ---
# [cite_start]Audits compliance with: Use strong passwords [cite: 114]
audit_password_policies() {
    printf "\n[CHECK] | 4. Auditing Password Policies...\n"
    policy=$(grep "pam_pwquality.so" /etc/pam.d/common-password)
    if [ -n "$policy" ]; then
        print_result "PASS" "Password quality module (pam_pwquality) is enforced."
    else
        print_result "FAIL" "No password quality module found in PAM configuration."
    fi
}

# --- 5. Audit File Permissions ---
# [cite_start]Audits compliance with: configure file permissions [cite: 115]
audit_file_permissions() {
    printf "\n[CHECK] | 5. Auditing Critical File Permissions...\n"
    sshd_perms=$(stat -c "%a" /etc/ssh/sshd_config)
    if [ "$sshd_perms" = "600" ]; then
        print_result "PASS" "/etc/ssh/sshd_config permissions are secure (600)."
    else
        print_result "FAIL" "/etc/ssh/sshd_config permissions are not 600 (are $sshd_perms)."
    fi
}

# --- 6. Audit For Malware Scanner ---
# [cite_start]Audits compliance with: Install and configure antivirus software [cite: 118]
audit_malware_scanner_installed() {
    printf "\n[CHECK] | 6. Auditing for Malware Scanner...\n"
    if command -v clamscan &> /dev/null; then
        print_result "PASS" "Malware scanner (ClamAV) is installed."
    else
        print_result "FAIL" "Malware scanner (ClamAV) is not installed."
    fi
}

# --- 7. Audit Logging Status ---
# [cite_start]Audits compliance with: Enable system logging and monitoring [cite: 121]
audit_logging_status() {
    printf "\n[CHECK] | 7. Auditing Logging Status...\n"
    status=$(systemctl is-active auditd)
    if [ "$status" = "active" ]; then
        print_result "PASS" "System auditing service (auditd) is active."
    else
        print_result "FAIL" "System auditing service (auditd) is inactive."
    fi
}

# --- 8. Audit For Principle of Least Privilege ---
# [cite_start]Audits compliance with: Implement the principle of least privilege (PoLP) [cite: 113]
audit_least_privilege() {
    printf "\n[CHECK] | 8. Auditing for Principle of Least Privilege (PoLP)...\n"
    privileged_users=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd)
    if [ -z "$privileged_users" ]; then
        print_result "PASS" "No non-root accounts with UID 0 found."
    else
        print_result "FAIL" "Found non-root accounts with UID 0: $privileged_users"
    fi
}

# --- 9. Audit File Integrity Checker ---
audit_aide_status() {
    printf "\n[CHECK] | 9. Auditing File Integrity Checker (AIDE)...\n"
    if command -v aide &> /dev/null; then
        print_result "PASS" "AIDE package is installed."
    else
        print_result "FAIL" "AIDE package is not installed."
        return
    fi

    if [ -f /var/lib/aide/aide.db.gz ]; then
        print_result "PASS" "AIDE baseline database exists."
    else
        print_result "FAIL" "AIDE baseline database does not exist. Run setup."
    fi
}

# --- Main Audit Function ---
run_all_audits() {
    printf "\n[EXEC] === EXECUTING ALL AUDIT MODULES ===\n"
    audit_automatic_updates
    audit_firewall_status
    audit_disabled_services
    audit_password_policies
    audit_file_permissions
    audit_malware_scanner_installed
    audit_logging_status
    audit_least_privilege
    audit_aide_status
    printf "\n[DONE] === ALL AUDIT MODULES EXECUTED ===\n"
}
