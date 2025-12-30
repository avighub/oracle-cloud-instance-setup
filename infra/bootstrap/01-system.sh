#!/bin/bash
set -e

echo "=== [01-system] Updating system packages ==="

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y
sudo apt upgrade -y

echo "=== [01-system] Installing base utilities ==="

sudo apt install -y \
  git \
  curl \
  wget \
  ufw \
  htop \
  ca-certificates \
  gnupg \
  lsb-release

echo "=== [01-system] Base system setup completed ==="