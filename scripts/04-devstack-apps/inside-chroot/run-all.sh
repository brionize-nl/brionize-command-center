#!/bin/bash
# Orchestreert fase 4 (devstack). Draait binnen chroot, als root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-nodejs.sh"
  "02-bun.sh"
  "03-gh.sh"
  "04-cloudflared.sh"
  "05-supabase-cli.sh"
  "06-tailscale.sh"
  "07-postgresql.sh"
  "08-sqlite.sh"
  "09-python-rebuild-sqlite3.sh"
  "10-n8n.sh"
  "11-pm2.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 04) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-04-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-04-$step.txt"
    exit 1
  fi
done

echo "==> Fase 4 (binnen chroot) volledig doorlopen"
