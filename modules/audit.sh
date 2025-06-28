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
# [cite_start]Audits compliance with: Enable automatic updates where possible [cite: 22]
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
# [cite_start]Audits compliance with: Configure firewall settings [cite: 23]
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
# [cite_start]Audits compliance with: Disable unnecessary services and features [cite: 22]
# This version now reads from the config file.
audit_disabled_services() {
    local config_file="config/services.conf"
    printf "\n[CHECK] | 3. Auditing for unnecessary services from '${config_file}'...\n"
    if [ ! -f "$config_file" ]; then
        print_result "FAIL" "Config file not found: ${config_file}"
        return
    fi

    while IFS= read -r service || [[ -n "$service" ]]; do
        [[ "$service" =~ ^# ]] || [[ -z "$service" ]] && continue
        status=$(systemctl is-enabled "$service" 2>/dev/null)
        if [ "$status" = "disabled" ] || [ "$status" = "masked" ]; then
            print_result "PASS" "Service '${service}' is disabled."
        else
            print_result "FAIL" "Service '${service}' is enabled (Status: ${status})."
        fi
    done < "$config_file"
}

# --- 4. Audit Password Policies ---
# [cite_start]Audits compliance with: Use strong passwords [cite: 25]
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
# [cite_start]Audits compliance with: configure file permissions [cite: 26]
# This version now reads from the config file.
audit_file_permissions() {
    local config_file="config/permissions.conf"
    printf "\n[CHECK] | 5. Auditing Critical File Permissions from '${config_file}'...\n"
    if [ ! -f "$config_file" ]; then
        print_result "FAIL" "Config file not found: ${config_file}"
        return
    fi

    while read -r file mode; do
        [[ "$file" =~ ^# ]] || [[ -z "$file" ]] && continue
        if [ -e "$file" ]; then
            current_perms=$(stat -c "%a" "$file")
            if [ "$current_perms" = "$mode" ]; then
                print_result "PASS" "Permissions for '${file}' are correct (${mode})."
            else
                print_result "FAIL" "Permissions for '${file}' are incorrect. Is: ${current_perms}, Should be: ${mode}."
            fi
        else
            print_result "WARN" "File not found for audit: ${file}"
        fi
    done < "$config_file"
}

# --- 6. Audit For Malware Scanner ---
# [cite_start]Audits compliance with: Install and configure antivirus software [cite: 29]
audit_malware_scanner_installed() {
    printf "\n[CHECK] | 6. Auditing for Malware Scanner...\n"
    if command -v clamscan &> /dev/null; then
        print_result "PASS" "Malware scanner (ClamAV) is installed."
    else
        print_result "FAIL" "Malware scanner (ClamAV) is not installed."
    fi
}

# --- 7. Audit Logging Status ---
# [cite_start]Audits compliance with: Enable system logging and monitoring [cite: 32]
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
# [cite_start]Audits compliance with: Implement the principle of least privilege (PoLP) [cite: 24]
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
