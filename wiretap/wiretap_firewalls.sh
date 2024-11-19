#!/bin/bash
# Will Rinko - Wiretap Firewalls - 11.19.24
echo "Setting up firewall rules..."
firewall-cmd --set-default-zone=public
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=imap
firewall-cmd --reload
echo "Firewall setup complete."
firewall-cmd --list-all