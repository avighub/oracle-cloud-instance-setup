#!/bin/bash
set -e

echo "=== [05-traefik] Setting up Traefik reverse proxy ==="

# -------- CONFIG --------
TRAEFIK_DIR="$HOME/apps/proxy/traefik"
if [[ ! -d "$TRAEFIK_DIR" ]]; then
  echo "Creating Traefik directory: $TRAEFIK_DIR"
  mkdir -p "$TRAEFIK_DIR"
else
  echo "Traefik directory already exists: $TRAEFIK_DIR"
fi
TRAEFIK_VERSION="v3.6.1"
ACME_EMAIL="add-valid-email-here"   # 🔴 CHANGE THIS to your email
NETWORK_NAME="web"
# ------------------------

# Validate ACME_EMAIL
if [[ -z "$ACME_EMAIL" ]]; then
  echo "ERROR: ACME_EMAIL is blank. Please set a valid email in 05-traefik.sh"
  exit 1
fi

# Simple email validation regex
EMAIL_REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
if ! [[ "$ACME_EMAIL" =~ $EMAIL_REGEX ]]; then
  echo "ERROR: ACME_EMAIL '$ACME_EMAIL' is not a valid email, Please set a valid email in 05-traefik.sh"
  exit 1
fi

echo "Using Traefik version: $TRAEFIK_VERSION"
echo "ACME email: $ACME_EMAIL"

# Create directories
echo "Creating Traefik directories..."
mkdir -p "$TRAEFIK_DIR/data"
cd "$TRAEFIK_DIR"

# Create acme.json securely
if [[ ! -f data/acme.json ]]; then
  echo "Creating acme.json"
  touch data/acme.json
  chmod 600 data/acme.json
else
  echo "acme.json already exists"
fi

# Create traefik.yml
echo "Writing traefik.yml"
cat > traefik.yml <<EOF
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: $ACME_EMAIL
      storage: /data/acme.json
      httpChallenge:
        entryPoint: web

providers:
  docker:
    exposedByDefault: false
EOF

# Create docker-compose.yml
echo "Writing docker-compose.yml"
cat > docker-compose.yml <<EOF
services:
  traefik:
    image: traefik:$TRAEFIK_VERSION
    container_name: traefik
    restart: unless-stopped

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.yml:/traefik.yml:ro
      - ./data:/data

    command:
      - "--configFile=/traefik.yml"

    networks:
      - $NETWORK_NAME

networks:
  $NETWORK_NAME:
    external: true
EOF

# Start Traefik
echo "Starting Traefik..."
docker compose up -d

echo "=== [05-traefik] Traefik setup completed ==="