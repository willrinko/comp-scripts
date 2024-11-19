#!/bin/bash
# Will Rinko - Propaganda SSH/DOCKER Secure - 11.19.24
echo "Securing SSH..."
sed -i 's/^#\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
sed -i 's/^#\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
systemctl enable sshd
systemctl restart sshd
echo "SSH secured."
echo "Securing Docker..."
cat <<EOF > /etc/docker/daemon.json
{
    "icc": false,
    "live-restore": true
}
EOF
systemctl enable docker
systemctl restart docker
echo "Docker secured."