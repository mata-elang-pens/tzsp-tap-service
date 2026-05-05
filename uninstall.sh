#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Stopping and disabling service..."
systemctl stop tzsp-tap || true
systemctl disable tzsp-tap || true

echo "[2/4] Removing service file..."
rm -f /etc/systemd/system/tzsp-tap.service

echo "[3/4] Removing binaries..."
rm -f /usr/local/bin/tzsp-tap
rm -f /usr/local/bin/tzsp2pcap

echo "[4/4] Reloading systemd..."
systemctl daemon-reload

echo "Done. tzsp-tap removed."
