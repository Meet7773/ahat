#!/bin/bash

# Threat Detection Module for A.H.A.T.
# Contains functions to scan for and report on potential threats.

# --- 1. File Integrity Check ---
# Uses AIDE to check for changes to critical files against a known baseline.
run_file_integrity_check() {
    printf "\n[INFO]  | 1. Running File Integrity Check with AIDE...\n"
    if command -v aide &> /dev/null; then
        if [ -f /var/lib/aide/aide.db.gz ]; then
            printf "[EXEC]  | AIDE database found. Comparing against current state. This may take a while...\n"
            aide --check
        else
            printf "[WARN]  | AIDE database not found. Please run the AIDE setup from the hardening menu first.\n"
        fi
    else
        printf "[WARN]  | AIDE is not installed. Please install it via the hardening menu.\n"
    fi
}

# --- 2. On-Demand Malware Scan ---
# Uses ClamAV to scan user home directories.
run_malware_scan() {
    printf "\n[INFO]  | 2. Running On-Demand Malware Scan with ClamAV...\n"
    if command -v clamscan &> /dev/null; then
        # Scans all home directories, showing only infected files.
        printf "[EXEC]  | Scanning all /home directories. This may take a while...\n"
        clamscan -r --infected /home
    else
        printf "[WARN]  | ClamAV is not installed. Please install it via the hardening menu.\n"
    fi
}

# --- 3. Authentication Log Analysis ---
# Parses /var/log/auth.log for suspicious activity.
analyze_auth_logs() {
    printf "\n[INFO]  | 3. Analyzing Authentication Logs (/var/log/auth.log)...\n"
    local auth_log="/var/log/auth.log"

    if [ -f "$auth_log" ]; then
        # Failed Logins
        printf "[REPORT]| === Failed SSH/Login Attempts ===\n"
        grep "Failed password" "$auth_log" | awk '{print "    - User:", $9, "From IP:", $11, "on", $1, $2, $3}'
        printf "\n"

        # Sudo Command Usage
        printf "[REPORT]| === Sudo Command Usage ===\n"
        grep "COMMAND=" "$auth_log" | awk -F ' ; ' '{print "    - User:", $2, "| Command:", $4, "| PWD:", $3}' | sed 's/USER=//;s/COMMAND=//;s/PWD=//'
        printf "\n"

        # Accepted Logins
        printf "[REPORT]| === Successful Logins ===\n"
        grep "Accepted password" "$auth_log" | awk '{print "    - User:", $9, "From IP:", $11, "on", $1, $2, $3}'
        printf "\n"
    else
        printf "[WARN]  | Log file not found: %s\n" "$auth_log"
    fi
}

# --- Main Threat Report Function ---
# This is the master function that calls all others and creates a report.
generate_threat_report() {
    local report_file="${LOG_DIR}/threat_report_$(date +%Y-%m-%d_%H-%M-%S).log"
    printf "\n[EXEC]  | Generating consolidated threat report...\n"
    printf "[INFO]  | Report will be saved to: %s\n" "$report_file"

    # Create the report header
    {
        echo "================================================="
        echo "  A.H.A.T. - Threat Detection Report"
        echo "  Generated on: $(date)"
        echo "================================================="
    } >> "$report_file"

    # Call each function and append its output to the report
    (
        run_file_integrity_check
        run_malware_scan
        analyze_auth_logs
    ) >> "$report_file" 2>&1

    printf "\n[DONE]  | Threat report generation complete.\n"
}
