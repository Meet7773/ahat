#!/bin/bash

# Hardening Module for A.H.A.T.
# Contains functions to apply security configurations.

# --- 1. Update and Patch Management ---
# [cite_start]Corresponds to: Regularly update the operating system (OS) [cite: 46] [cite_start]and Enable automatic updates where possible to ensure timely patching [cite: 47]
# This function now sets up the official unattended-upgrades service.
setup_automatic_updates() {
    printf "\n[INFO]  | 1. Setting up automatic security updates via unattended-upgrades...\n"
    
    # First, run a manual update to bring the system current
    printf "[INFO]  |    Running initial system update...\n"
    apt-get update -y
    apt-get upgrade -y
    
    # Install the package if it's not already present
    printf "[INFO]  |    Installing unattended-upgrades package...\n"
    apt-get install unattended-upgrades -y
    
    # Create the configuration file to enable it.
    printf "[INFO]  |    Creating auto-upgrades configuration...\n"
    cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

    # Reconfigure the package to apply the new settings
    dpkg-reconfigure -plow unattended-upgrades

    printf "[OK]    | System is now configured to install security updates automatically.\n"
}

# --- 2. Secure Configuration ---
# [cite_start]Corresponds to: Configure firewall settings to restrict unnecessary network traffic [cite: 48]
apply_firewall_rules() {
    printf "\n[INFO]  | 2a. Configuring firewall (UFW)...\n"
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    echo "y" | ufw enable
    printf "[OK]    | Firewall is configured and enabled.\n"
}

# [cite_start]Corresponds to: Disable unnecessary services and features [cite: 48]
disable_unnecessary_services() {
    printf "\n[INFO]  | 2b. Disabling unnecessary services...\n"
    systemctl stop telnet.socket
    systemctl disable telnet.socket
    printf "[OK]    | Telnet service disabled.\n"
}

# --- 3. User Accounts and Privileges ---
# [cite_start]Corresponds to: Use strong passwords [cite: 50]
enforce_password_policies() {
    printf "\n[INFO]  | 3. Enforcing strong password policies via PAM...\n"
    apt-get install libpam-pwquality -y
    # Set password policies: min length=12, 3 different from old, at least 1 of each credit type
    sed -i 's/password\s*requisite\s*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
    printf "[OK]    | Password policies enforced using libpam-pwquality.\n"
}

# --- 4. File System Security ---
# [cite_start]Corresponds to: configure file permissions to restrict access based on user roles [cite: 51]
set_secure_file_permissions() {
    printf "\n[INFO]  | 4. Setting secure permissions on critical files...\n"
    chmod 600 /etc/ssh/sshd_config
    chmod 640 /etc/shadow
    chmod 440 /etc/sudoers
    printf "[OK]    | Permissions set for sshd_config, shadow, and sudoers.\n"
}

# --- 6. Malware Protection ---
# [cite_start]Corresponds to: Install and configure antivirus software [cite: 55]
install_malware_scanner() {
    printf "\n[INFO]  | 6. Installing malware scanner (ClamAV)...\n"
    apt-get install clamav clamav-daemon -y
    freshclam # Update signatures
    printf "[OK]    | ClamAV installed and signatures updated.\n"
}

# --- 8. Monitoring and Logging ---
# [cite_start]Corresponds to: Enable auditing and logging to monitor file access and changes [cite: 52] [cite_start]and Enable system logging and monitoring [cite: 57]
enable_system_auditing() {
    printf "\n[INFO]  | 8. Installing and enabling system auditing (auditd)...\n"
    apt-get install auditd -y
    systemctl enable --now auditd
    printf "[OK]    | auditd installed and enabled.\n"
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
    printf "\n[DONE] === ALL HARDENING MODULES APPLIED ===\n"
}
