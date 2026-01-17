#!/bin/bash
set -e

DOMAIN="add-your-domain-here"  # <-- CHANGE THIS to your test domain
NETWORK_NAME="web"
ROUTER_NAME=$(echo "$DOMAIN" | tr '.' '-' | tr '[:upper:]' '[:lower:]')
CONTAINER_NAME=$ROUTER_NAME-whoami

echo "=== [whoami-test-site] Setting up whoami-test-site for $DOMAIN ==="

# -------- CONFIG --------
APP_DIR="$HOME/apps/websites/$ROUTER_NAME"

# Validate DOMAIN
if [[ "$DOMAIN" == "add-your-domain-here" ]] || [[ -z "$DOMAIN" ]]; then
  echo "ERROR: DOMAIN is not set to a valid domain. Please update  DOMAIN to your actual domain in whoami-test-site-with-domain.sh"
  exit 1
fi

if [[ ! -d "$APP_DIR" ]]; then
  echo "Creating whoami-test-site directory: $APP_DIR"
  mkdir -p "$APP_DIR"
else
  echo "Whoami-test-site directory already exists: $APP_DIR"
fi

# ------------------------

echo "App directory: $APP_DIR"
echo "Domain: $DOMAIN"

# Create directory structure
echo "Creating directories..."
mkdir -p "$APP_DIR/html"
cd "$APP_DIR"

# Write index.html (only if not exists)
if [[ ! -f html/index.html ]]; then
  echo "Creating index.html"
  cat > html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>$DOMAIN</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
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
      box-shadow: 0 10px 30px rgba(0,0,0,.4);
    }
    h1 {
      margin-bottom: .5rem;
      font-size: 2rem;
    }
    p {
      color: #94a3b8;
      margin-top: 0;
    }
  </style>
</head>
<body>
  <div class="box">
    <h1>🚀 whoami-test-site</h1>
    <p>Your Website is working correctly. Replace this with original website content.</p>
  </div>
</body>
</html>
EOF
else
  echo "index.html already exists, skipping"
fi

# Write docker-compose.yml
echo "Writing docker-compose.yml"
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

      # 🔑 tell Traefik which Docker network to use
      - "traefik.docker.network=web"

      # 🔑 HTTPS ROUTER
      - "traefik.http.routers.$ROUTER_NAME.rule=Host(\`$DOMAIN\`)"
      - "traefik.http.routers.$ROUTER_NAME.entrypoints=websecure"

      # 🔑 HTTP ROUTER
      - "traefik.http.routers.$ROUTER_NAME-http.rule=Host(\`$DOMAIN\`)"
      - "traefik.http.routers.$ROUTER_NAME-http.entrypoints=web"
      - "traefik.http.routers.$ROUTER_NAME-http.service=$ROUTER_NAME"
      - "traefik.http.routers.$ROUTER_NAME.tls=true"
      - "traefik.http.routers.$ROUTER_NAME.tls.certresolver=letsencrypt"
      - "traefik.http.services.$ROUTER_NAME.loadbalancer.server.port=80"
      
    networks:
      - $NETWORK_NAME

networks:
  $NETWORK_NAME:
    external: true
EOF

# Start the container
echo "Starting whoami-test-site container..."
docker compose up -d

echo "=== [whoami-test-site] whoami-test-site deployed ==="
echo "Test with: https://$DOMAIN"
echo "Make sure your domain's DNS is pointing to this server's IP."
echo "Terminate the docker container when testing is done, to save resources."
