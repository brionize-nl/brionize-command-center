#!/bin/bash
# Orchestreert fase 5b (WebKitGTK-kiosk-shell + generiek "voeg webapp
# toe"-mechanisme). Draait binnen chroot, als root. Zie BLUEPRINT.md
# "UX-herziening: Tegel-manager & Visuele laag" (2026-09-26), sectie
# "PWA's/webapps — generiek, niet hardcoded".
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-build-kiosk-shell.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 05b) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-05b-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-05b-$step.txt"
    exit 1
  fi
done

echo "==> Fase 5b (binnen chroot) volledig doorlopen"
