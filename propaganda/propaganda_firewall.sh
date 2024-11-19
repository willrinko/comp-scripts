#!/bin/bash
# Will Rinko - Propaganda Firewalls - 11.19.24
echo "Setting up UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 2375/tcp  # Docker (find out if required)
ufw enable
echo "Firewall setup complete."