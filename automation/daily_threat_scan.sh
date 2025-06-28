#!/bin/bash

# A.H.A.T. - Daily Threat Scan Automation Script
# Designed to be run by cron. This script is non-interactive.

# Find the script's own directory to reliably source modules
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="${SCRIPT_DIR}/.."

# The LOG_DIR variable is needed by the sourced threat_detection module
LOG_DIR="${PROJECT_ROOT}/log"

# Source the required functions
source "${PROJECT_ROOT}/modules/threat_detection.sh"

# --- Execution ---
# The generate_threat_report function already handles creating its own
# timestamped log file, so we just need to call it.
generate_threat_report

# We can add a master log entry to confirm the cron job ran.
echo "Daily Threat Scan triggered via cron on $(date)" >> "${LOG_DIR}/automation_master.log"
