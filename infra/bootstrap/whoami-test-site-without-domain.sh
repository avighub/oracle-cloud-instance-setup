#!/bin/bash
set -e

echo "=== [whoami-test-site] Setting up generic site (IP-based test) ==="

# -------- CONFIG --------
APP_DIR="$HOME/apps/whoami-test-site"

if [[ ! -d "$APP_DIR" ]]; then
  echo "Creating whoami-test-site directory: $APP_DIR"
  mkdir -p "$APP_DIR"
else
  echo "whoami-test-site directory already exists: $APP_DIR"
fi

NETWORK_NAME="web"
CONTAINER_NAME="whoami-test-site"
# ------------------------

echo "App directory: $APP_DIR"

# Create directory structure
mkdir -p "$APP_DIR/html"
cd "$APP_DIR"

# Create index.html if not exists
if [[ ! -f html/index.html ]]; then
  cat > html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>whoami-test-site</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    body {
      font-family: system-ui, sans-serif;
      background: #0f172a;
      color: #e5e7eb;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
    }
    .box {
      text-align: center;
      padding: 2rem;
      border-radius: 12px;
      background: #020617;
    }
  </style>
</head>
<body>
  <div class="box">
    <h1>🚀 whoami-test-site</h1>
    <p>Infrastructure is working correctly.</p>
  </div>
</body>
</html>
EOF
else
  echo "index.html already exists, skipping"
fi

# Create docker-compose.yml
cat > docker-compose.yml <<EOF
services:
  whoami:
    image: nginx:alpine
    container_name: $CONTAINER_NAME
    restart: unless-stopped

    volumes:
      - ./html:/usr/share/nginx/html:ro

    labels:
      - "traefik.enable=true"

      # HTTPS router (IP-based test)
      - "traefik.http.routers.whoami-test-site.rule=PathPrefix(`/`)"
      - "traefik.http.routers.whoami-test-site.entrypoints=websecure"
      - "traefik.http.routers.whoami-test-site.tls=true"
      - "traefik.http.services.whoami-test-site.loadbalancer.server.port=80"

    networks:
      - $NETWORK_NAME

networks:
  $NETWORK_NAME:
    external: true
EOF

# Start container
docker compose up -d

echo "=== [whoami-test-site] whoami-test-site deployed ==="
echo "Test with: http://<PUBLIC_IP>"