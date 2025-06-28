#!/bin/bash

# A.H.A.T. - Automated Hardening & Auditing Toolkit
#
# This toolkit applies and audits security configurations on Debian-based systems.
# It should be run with root privileges.

# --- Configuration ---
LOG_DIR="log"
MODULES_DIR="modules"
AUTOMATION_DIR="automation"
LOG_FILE="${LOG_DIR}/ahat_run_$(date +%Y-%m-%d_%H-%M-%S).log"

# --- Setup ---
# Create necessary directories
mkdir -p "$LOG_DIR"
mkdir -p "$AUTOMATION_DIR"
mkdir -p "$MODULES_DIR"

# Redirect all output to screen and log file
exec > >(tee -a "${LOG_FILE}") 2>&1

# --- Sourcing Modules ---
if [ -f "${MODULES_DIR}/harden.sh" ] && [ -f "${MODULES_DIR}/audit.sh" ] && [ -f "${MODULES_DIR}/threat_detection.sh" ]; then
    source "${MODULES_DIR}/harden.sh"
    source "${MODULES_DIR}/audit.sh"
    source "${MODULES_DIR}/threat_detection.sh"
else
    printf "[CRITICAL] Core module files not found in '${MODULES_DIR}/'. Please create them first. Exiting.\n"
    exit 1
fi

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   printf "[CRITICAL] This script must be run as root. Aborting.\n"
   exit 1
fi

# --- Automation Setup Function ---
setup_automation() {
    printf "\n[INFO]  | Setting up automation with cron...\n"
    
    PROJECT_PATH=$(pwd)
    AUDIT_SCRIPT_PATH="${PROJECT_PATH}/${AUTOMATION_DIR}/weekly_audit.sh"
    
    if [ ! -f "$AUDIT_SCRIPT_PATH" ]; then
        printf "[ERROR] | Automation script 'weekly_audit.sh' not found in '${AUTOMATION_DIR}/'. Aborting.\n"
        printf "[INFO]  | Please ensure 'weekly_audit.sh' exists before setting up automation.\n"
        return
    fi
    
    chmod +x "$AUDIT_SCRIPT_PATH"
    CRON_AUDIT="5 3 * * 0 ${AUDIT_SCRIPT_PATH}"
    (crontab -l 2>/dev/null | grep -v -F "$AUDIT_SCRIPT_PATH" ; echo "$CRON_AUDIT") | crontab -
    
    printf "[OK]    | Cron jobs created/updated successfully.\n"
    printf "[INFO]  | A full system audit will now run automatically every Sunday at 3:05 AM.\n"
    printf "[INFO]  | Note: Automatic updates are handled by the 'unattended-upgrades' service, not cron.\n"
    printf "[INFO]  | Check log files in the 'log' directory for results.\n"
}

# --- Menu Functions ---
show_main_menu() {
    printf "\n"
    printf "=================================================\n"
    printf "  A.H.A.T. - Automated Hardening & Auditing Toolkit\n"
    printf "=================================================\n"
    printf "  Log file for this session: %s\n\n" "$LOG_FILE"
    printf "   [H]ardening Modules (Manual)\n"
    printf "   [A]uditing Modules (Manual)\n"
    printf "   [T]hreat Detection & Reporting\n"
    printf "   [S]etup Background Automation (Cron for Audits)\n"
    printf "   [Q]uit\n"
    printf "\n"
}

run_hardening_menu() {
    printf "\n--- Hardening Modules ---\n"
    printf "1.  Apply ALL Hardening Modules\n"
    printf "2.  Setup Automatic Security Updates\n"
    printf "3.  Configure Firewall (UFW)\n"
    printf "4.  Disable Unnecessary Services\n"
    printf "5.  Enforce Strong Password Policies\n"
    printf "6.  Set Secure File Permissions\n"
    printf "7.  Install Malware Scanner (ClamAV)\n"
    printf "8.  Enable System Logging (auditd)\n"
    printf "9.  Setup File Integrity Checker (AIDE)\n"
    printf "10. Return to Main Menu\n"
    read -p "Select an option: " choice
    case $choice in
        1) apply_all_hardening ;;
        2) setup_automatic_updates ;;
        3) apply_firewall_rules ;;
        4) disable_unnecessary_services ;;
        5) enforce_password_policies ;;
        6) set_secure_file_permissions ;;
        7) install_malware_scanner ;;
        8) enable_system_auditing ;;
        9) setup_file_integrity_checker ;;
        10) return ;;
        *) printf "[WARN] Invalid option. Returning to menu.\n" ;;
    esac
    read -p "Press [Enter] to continue..."
    run_hardening_menu
}

run_auditing_menu() {
    printf "\n--- Auditing Modules ---\n"
    printf "1.  Run ALL Audit Modules\n"
    printf "2.  Audit Automatic Update Config\n"
    printf "3.  Audit Firewall Status\n"
    printf "4.  Audit For Unnecessary Services\n"
    printf "5.  Audit Password Policies\n"
    printf "6.  Audit File Permissions\n"
    printf "7.  Audit For Malware Scanner\n"
    printf "8.  Audit Logging Status\n"
    printf "9.  Audit For Principle of Least Privilege (PoLP)\n"
    printf "10. Audit File Integrity Checker (AIDE)\n"
    printf "11. Return to Main Menu\n"
    read -p "Select an option: " choice
    case $choice in
        1) run_all_audits ;;
        2) audit_automatic_updates ;;
        3) audit_firewall_status ;;
        4) audit_disabled_services ;;
        5) audit_password_policies ;;
        6) audit_file_permissions ;;
        7) audit_malware_scanner_installed ;;
        8) audit_logging_status ;;
        9) audit_least_privilege ;;
        10) audit_aide_status ;;
        11) return ;;
        *) printf "[WARN] Invalid option. Returning to menu.\n" ;;
    esac
    read -p "Press [Enter] to continue..."
    run_auditing_menu
}

run_threat_detection_menu() {
    printf "\n--- Threat Detection & Reporting ---\n"
    printf "1.  Generate Consolidated Threat Report\n"
    printf "2.  Run File Integrity Check (AIDE)\n"
    printf "3.  Run On-Demand Malware Scan (ClamAV)\n"
    printf "4.  Analyze Authentication Logs\n"
    printf "5.  Return to Main Menu\n"
    read -p "Select an option: " choice
    case $choice in
        1) generate_threat_report ;;
        2) run_file_integrity_check ;;
        3) run_malware_scan ;;
        4) analyze_auth_logs ;;
        5) return ;;
        *) printf "[WARN] Invalid option. Returning to menu.\n" ;;
    esac
    read -p "Press [Enter] to continue..."
    run_threat_detection_menu
}

# --- Main Loop ---
while true; do
    show_main_menu
    read -p "Select a menu [H/A/T/S/Q]: " main_choice
    case $main_choice in
        [Hh])
            run_hardening_menu
            ;;
        [Aa])
            run_auditing_menu
            ;;
        [Tt])
            run_threat_detection_menu
            ;;
        [Ss])
            setup_automation
            read -p "Press [Enter] to continue..."
            ;;
        [Qq])
            printf "Exiting toolkit.\n"
            exit 0
            ;;
        *)
            printf "[WARN] Invalid selection.\n"
            ;;
    esac
done
