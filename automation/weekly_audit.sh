#!/bin/bash

# A.H.A.T. - Weekly Audit Automation Script
# Designed to be run by cron. This script is non-interactive.

# Find the script's own directory to reliably source modules
# This is crucial for running correctly from cron
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="${SCRIPT_DIR}/.."
LOG_FILE="${PROJECT_ROOT}/log/weekly_audit.log"

# Source the required functions
source "${PROJECT_ROOT}/modules/audit.sh"

# --- Execution ---
# Log the start time, appending to the log file
{
    echo "================================================="
    echo "  A.H.A.T. - Weekly Audit Run"
    echo "  Started on: $(date)"
    echo "================================================="
    echo ""
} >> "$LOG_FILE"

# Call the full audit function and append its output to the log
run_all_audits >> "$LOG_FILE" 2>&1

# Log the end time
{
    echo ""
    echo "--- Weekly Audit Run Finished: $(date) ---"
    echo "================================================="
    echo "" # Add newlines for spacing
    echo ""
} >> "$LOG_FILE"
