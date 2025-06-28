#!/bin/bash

# Hardening Module for A.H.A.T.
# Contains functions to apply security configurations.

# --- 1. Update and Patch Management ---
# [cite_start]Corresponds to: Regularly update the operating system (OS) [cite: 21] [cite_start]and Enable automatic updates where possible to ensure timely patching [cite: 22]
setup_automatic_updates() {
    printf "\n[INFO]  | 1. Setting up automatic security updates via unattended-upgrades...\n"
    printf "[INFO]  |    Running initial system update...\n"
    apt-get update -y
    apt-get upgrade -y
    printf "[INFO]  |    Installing unattended-upgrades package...\n"
    apt-get install unattended-upgrades -y
    printf "[INFO]  |    Creating auto-upgrades configuration...\n"
    cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
    dpkg-reconfigure -plow unattended-upgrades
    printf "[OK]    | System is now configured to install security updates automatically.\n"
}

# --- 2. Secure Configuration ---
# [cite_start]Corresponds to: Configure firewall settings to restrict unnecessary network traffic [cite: 23]
apply_firewall_rules() {
    printf "\n[INFO]  | 2a. Configuring firewall (UFW)...\n"
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    echo "y" | ufw enable
    printf "[OK]    | Firewall is configured and enabled.\n"
}

# [cite_start]Corresponds to: Disable unnecessary services and features [cite: 22]
# This version now reads from the config file.
disable_unnecessary_services() {
    local config_file="config/services.conf"
    printf "\n[INFO]  | 2b. Disabling unnecessary services from '${config_file}'...\n"
    if [ ! -f "$config_file" ]; then
        printf "[WARN]  | Config file not found: %s\n" "$config_file"
        return
    fi
    
    while IFS= read -r service || [[ -n "$service" ]]; do
        # Ignore comments and empty lines
        [[ "$service" =~ ^# ]] || [[ -z "$service" ]] && continue
        systemctl disable --now "$service" >/dev/null 2>&1
        printf "[OK]    | Service '%s' disabled.\n" "$service"
    done < "$config_file"
}

# --- 3. User Accounts and Privileges ---
# [cite_start]Corresponds to: Use strong passwords [cite: 25]
enforce_password_policies() {
    printf "\n[INFO]  | 3. Enforcing strong password policies via PAM...\n"
    apt-get install libpam-pwquality -y
    sed -i 's/password\s*requisite\s*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
    printf "[OK]    | Password policies enforced using libpam-pwquality.\n"
}

# --- 4. File System Security ---
# [cite_start]Corresponds to: configure file permissions to restrict access based on user roles [cite: 26]
# This version now reads from the config file.
set_secure_file_permissions() {
    local config_file="config/permissions.conf"
    printf "\n[INFO]  | 4. Setting secure permissions on critical files from '${config_file}'...\n"
    if [ ! -f "$config_file" ]; then
        printf "[WARN]  | Config file not found: %s\n" "$config_file"
        return
    fi

    while read -r file mode; do
        # Ignore comments and empty lines
        [[ "$file" =~ ^# ]] || [[ -z "$file" ]] && continue
        if [ -e "$file" ]; then
            chmod "$mode" "$file"
            printf "[OK]    | Permissions for '%s' set to %s.\n" "$file" "$mode"
        else
            printf "[WARN]  | File not found, cannot set permissions: %s\n" "$file"
        fi
    done < "$config_file"
}

# --- 6. Malware Protection ---
# [cite_start]Corresponds to: Install and configure antivirus software or endpoint protection [cite: 29]
install_malware_scanner() {
    printf "\n[INFO]  | 6. Installing malware scanner (ClamAV)...\n"
    apt-get install clamav clamav-daemon -y
    freshclam
    printf "[OK]    | ClamAV installed and signatures updated.\n"
}

# --- 8. Monitoring and Logging ---
# [cite_start]Corresponds to: Enable auditing and logging to monitor file access and changes [cite: 27] [cite_start]and Enable system logging and monitoring [cite: 32]
enable_system_auditing() {
    printf "\n[INFO]  | 8. Installing and enabling system auditing (auditd)...\n"
    apt-get install auditd -y
    systemctl enable --now auditd
    printf "[OK]    | auditd installed and enabled.\n"
}

# --- 9. File Integrity Monitoring ---
# This supports the principle of monitoring and auditing to detect unauthorized changes.
setup_file_integrity_checker() {
    printf "\n[INFO]  | 9. Installing and Initializing File Integrity Checker (AIDE)...\n"
    apt-get install aide aide-common -y
    printf "[EXEC]  | Initializing AIDE database. This is a one-time setup and will take a significant amount of time...\n"
    aideinit
    cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    printf "[OK]    | AIDE has been installed and its baseline database created.\n"
}

# --- Main Hardening Function ---
apply_all_hardening() {
    printf "\n[EXEC] === EXECUTING ALL HARDENING MODULES ===\n"
    setup_automatic_updates
    apply_firewall_rules
    disable_unnecessary_services
    enforce_password_policies
    set_secure_file_permissions
    install_malware_scanner
    enable_system_auditing
    setup_file_integrity_checker
    printf "\n[DONE] === ALL HARDENING MODULES APPLIED ===\n"
}
