#!/bin/bash
set -e

echo "=== [02-docker] Installing Docker ==="

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
  echo "Docker already installed, skipping installation."
else
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
fi

echo "=== [02-docker] Enabling and starting Docker service ==="

sudo systemctl enable docker
sudo systemctl start docker

echo "=== [02-docker] Adding user '$USER' to docker group ==="

if groups "$USER" | grep -q docker; then
  echo "User already in docker group."
else
  sudo usermod -aG docker "$USER"
  echo "User added to docker group. You must re-login or run 'newgrp docker'."
fi

echo "=== [02-docker] Creating shared Docker network (web) ==="

# Create shared Docker network for reverse proxy if it doesn't exist
if sudo docker network inspect web >/dev/null 2>&1; then
  echo "Docker network 'web' already exists."
else
  sudo docker network create web
  echo "Docker network 'web' created."
fi

echo "=== [02-docker] Docker setup completed ==="