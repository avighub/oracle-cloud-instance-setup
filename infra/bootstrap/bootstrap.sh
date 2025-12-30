#!/bin/bash
set -e

echo "=========================================="
echo " Oracle Cloud VM Bootstrap Started"
echo " Host: $(hostname)"
echo " User: $(whoami)"
echo " Time: $(date)"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure scripts are executable
chmod +x "$SCRIPT_DIR"/*.sh

echo
echo ">>> Step 1: Base system setup"
"$SCRIPT_DIR/01-system.sh"

echo
echo ">>> Step 2: Docker installation"
"$SCRIPT_DIR/02-docker.sh"

echo
echo ">>> Step 3: Firewall configuration"
"$SCRIPT_DIR/03-firewall.sh"

echo
echo ">>> Step 4: Swap configuration"
"$SCRIPT_DIR/04-swap.sh"

echo
echo "=========================================="
echo " Bootstrap completed successfully ✅"
echo
echo " IMPORTANT NEXT STEPS:"
echo " 1. Run: newgrp docker   (or logout/login)"
echo " 2. Verify Docker: docker run hello-world"
echo " 3. Verify Swap: free -h"
echo "=========================================="