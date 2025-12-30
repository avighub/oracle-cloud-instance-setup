#!/bin/bash
set -e

echo "=== [03-firewall] Configuring UFW firewall ==="

# Ensure SSH is allowed (critical to avoid lockout)
sudo ufw allow OpenSSH

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable UFW if not already enabled
if sudo ufw status | grep -q "Status: active"; then
  echo "UFW already enabled."
else
  sudo ufw --force enable
  echo "UFW enabled."
fi

echo "=== [03-firewall] Firewall configuration completed ==="