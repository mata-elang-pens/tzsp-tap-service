#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/4] Installing tzsp-tap binary..."
cp "$SCRIPT_DIR/tzsp-tap" /usr/local/bin/tzsp-tap
chmod +x /usr/local/bin/tzsp-tap

echo "[2/4] Installing systemd service..."
cp "$SCRIPT_DIR/tzsp-tap.service" /etc/systemd/system/tzsp-tap.service

echo "[3/4] Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable tzsp-tap

echo "[4/4] Starting service..."
systemctl start tzsp-tap

echo ""
echo "Done. Status:"
systemctl status tzsp-tap --no-pager
