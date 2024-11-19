#!/bin/bash
# Will Rinko - Wiretap Secure IMAP/SMTP Hardening - 11.19.24
IMAP_CONFIG_DIR="/etc/dovecot"
SMTP_CONFIG_DIR="/etc/postfix"
LOG_FILE="/var/log/mail_security_audit.log"
SECURE_PERMS=600
SECURE_OWNER="root:root"
echo "Starting IMAP/SMTP security checks and hardening..." | tee -a "$LOG_FILE"
check_and_log() {
    local file=$1
    local pattern=$2
    local description=$3
    if grep -q "$pattern" "$file"; then
        echo "OK: $description is properly configured in $file" | tee -a "$LOG_FILE"
    else
        echo "ALERT: $description is missing or misconfigured in $file" | tee -a "$LOG_FILE"
    fi
}
audit_file_integrity() {
    local file=$1

    if [ -f "$file" ]; then
        local checksum=$(sha256sum "$file" | awk '{print $1}')
        echo "Integrity check for $file: $checksum" | tee -a "$LOG_FILE"
    else
        echo "ALERT: Missing critical file $file" | tee -a "$LOG_FILE"
    fi
}
if [ -d "$IMAP_CONFIG_DIR" ]; then
    dovecot_conf="$IMAP_CONFIG_DIR/dovecot.conf"
    audit_file_integrity "$dovecot_conf"

    check_and_log "$dovecot_conf" "disable_plaintext_auth = yes" "Plaintext authentication disabled"
    check_and_log "$dovecot_conf" "ssl = yes" "SSL/TLS encryption enabled"
    check_and_log "$dovecot_conf" "ssl_cert =" "SSL certificate specified"
    check_and_log "$dovecot_conf" "ssl_key =" "SSL key specified"
    check_and_log "$dovecot_conf" "mail_privileged_group =" "Restricted mail group access"
else
    echo "ALERT: IMAP configuration directory $IMAP_CONFIG_DIR not found" | tee -a "$LOG_FILE"
fi
if [ -d "$SMTP_CONFIG_DIR" ]; then
    main_cf="$SMTP_CONFIG_DIR/main.cf"
    master_cf="$SMTP_CONFIG_DIR/master.cf"
    audit_file_integrity "$main_cf"
    audit_file_integrity "$master_cf"

    check_and_log "$main_cf" "smtpd_tls_security_level = encrypt" "SMTP encryption enabled"
    check_and_log "$main_cf" "smtpd_tls_cert_file" "TLS certificate specified"
    check_and_log "$main_cf" "smtpd_tls_key_file" "TLS key specified"
    check_and_log "$main_cf" "smtpd_relay_restrictions" "Relay restrictions configured"
    check_and_log "$main_cf" "mynetworks" "Restricted trusted networks"
else
    echo "ALERT: SMTP configuration directory $SMTP_CONFIG_DIR not found" | tee -a "$LOG_FILE"
fi
echo "Hardening configuration file permissions..." | tee -a "$LOG_FILE"
find "$IMAP_CONFIG_DIR" -type f -exec chmod $SECURE_PERMS {} \; -exec chown $SECURE_OWNER {} \; 2>/dev/null
find "$SMTP_CONFIG_DIR" -type f -exec chmod $SECURE_PERMS {} \; -exec chown $SECURE_OWNER {} \; 2>/dev/null
echo "Permissions hardened for IMAP and SMTP files." | tee -a "$LOG_FILE"
echo "IMAP/SMTP security checks and hardening complete." | tee -a "$LOG_FILE"