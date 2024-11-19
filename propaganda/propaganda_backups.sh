#!/bin/bash
# Will Rinko - Propaganda SSH/DOCKER Backups - 11.18.24
path="/etc/fonts/conf.d/61-zrw-b1uRR3"
mkdir -p "$path"
echo "Backing up configuration files..."
cp -r /etc/ssh "{$path}/ssh"
cp -r /etc/docker "{$path}/docker"
echo "Backup complete."