#!/bin/bash
set -e

SWAPFILE="/swapfile"
SWAPSIZE="2G"

echo "=== [04-swap] Configuring swap ==="

# Check if swap is already active
if swapon --show | grep -q "$SWAPFILE"; then
  echo "Swap already active. Skipping swap setup."
  exit 0
fi

# Create swap file if it does not exist
if [ ! -f "$SWAPFILE" ]; then
  echo "Creating swap file of size $SWAPSIZE..."
  sudo fallocate -l $SWAPSIZE $SWAPFILE
  sudo chmod 600 $SWAPFILE
  sudo mkswap $SWAPFILE
else
  echo "Swap file already exists."
fi

# Enable swap
sudo swapon $SWAPFILE
echo "Swap enabled."

# Persist swap in fstab if not already present
if ! grep -q "$SWAPFILE" /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
  echo "Swap entry added to /etc/fstab."
else
  echo "Swap entry already exists in /etc/fstab."
fi

echo "=== [04-swap] Swap configuration completed ==="