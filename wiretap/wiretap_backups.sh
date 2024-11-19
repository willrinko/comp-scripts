#!/bin/bash
# Will Rinko - Wiretap Backups - 11.19.24
BACKUP_DIR="/etc/fonts/conf.d/61-zrw-b1uRR3"
IMAP_CONFIG_DIR="/etc/dovecot"
SMTP_CONFIG_DIR="/etc/postfix"
LOG_FILE="/var/log/mail_backup.log"
echo "Backing up IMAP/SMTP configuration files..." | tee -a "$LOG_FILE"
mkdir -p "$BACKUP_DIR"
if [ -d "$IMAP_CONFIG_DIR" ]; then
    cp -r "$IMAP_CONFIG_DIR" "$BACKUP_DIR/dovecot_backup"
    echo "IMAP configuration files copied." | tee -a "$LOG_FILE"
else
    echo "IMAP configuration directory not found: $IMAP_CONFIG_DIR" | tee -a "$LOG_FILE"
fi
if [ -d "$SMTP_CONFIG_DIR" ]; then
    cp -r "$SMTP_CONFIG_DIR" "$BACKUP_DIR/postfix_backup"
    echo "SMTP configuration files copied." | tee -a "$LOG_FILE"
else
    echo "SMTP configuration directory not found: $SMTP_CONFIG_DIR" | tee -a "$LOG_FILE"
fi
echo "Backup operations completed." | tee -a "$LOG_FILE"