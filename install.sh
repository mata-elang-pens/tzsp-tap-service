#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src/tzsp2pcap"

# ── 1. Dependencies ──────────────────────────────────────────────────────────
echo "[1/6] Installing build dependencies..."
apt-get install -y --no-install-recommends git make gcc libpcap-dev

# ── 2. Clone tzsp2pcap ───────────────────────────────────────────────────────
echo "[2/6] Cloning tzsp2pcap..."
if [ -d "$SRC_DIR/.git" ]; then
    echo "  already cloned, pulling latest..."
    git -C "$SRC_DIR" pull --ff-only
else
    mkdir -p "$(dirname "$SRC_DIR")"
    git clone https://github.com/thefloweringash/tzsp2pcap.git "$SRC_DIR"
fi

# ── 3. Build tzsp2pcap ───────────────────────────────────────────────────────
echo "[3/6] Building tzsp2pcap..."
make -C "$SRC_DIR" -j"$(nproc)"

echo "  installing tzsp2pcap to /usr/local/bin..."
cp "$SRC_DIR/tzsp2pcap" /usr/local/bin/tzsp2pcap
chmod +x /usr/local/bin/tzsp2pcap

# ── 4. Install tzsp-tap ──────────────────────────────────────────────────────
echo "[4/6] Installing tzsp-tap binary..."
cp "$SCRIPT_DIR/tzsp-tap" /usr/local/bin/tzsp-tap
chmod +x /usr/local/bin/tzsp-tap

# ── 5. Install systemd service ───────────────────────────────────────────────
echo "[5/6] Installing systemd service..."
cp "$SCRIPT_DIR/tzsp-tap.service" /etc/systemd/system/tzsp-tap.service
systemctl daemon-reload
systemctl enable tzsp-tap

# ── 6. Start service ─────────────────────────────────────────────────────────
echo "[6/6] Starting tzsp-tap service..."
systemctl start tzsp-tap

echo ""
echo "Done. Installed:"
echo "  /usr/local/bin/tzsp2pcap  (MikroTik TZSP pcap dumper)"
echo "  /usr/local/bin/tzsp-tap   (TZSP → TAP0 bridge)"
echo ""
echo "Service status:"
systemctl status tzsp-tap --no-pager
