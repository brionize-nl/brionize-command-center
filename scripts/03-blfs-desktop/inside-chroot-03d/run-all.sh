#!/bin/bash
# Orchestreert fase 3d (Conky-HUD, window-tiling, 3 werkbladen/
# hotkeys). Draait binnen chroot, als root. Zie BLUEPRINT.md "Fase 3d".
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-lua.sh"
  "02-wmctrl.sh"
  "03-devilspie2.sh"
  "04-conky.sh"
  "05-workspaces-hotkeys.sh"
  "06-theme-command-center-matrix.sh"
  "07-devilspie2-tiling-rules.sh"
  "08-autostart.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 03d) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-03d-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-03d-$step.txt"
    exit 1
  fi
done

echo "==> Fase 3d (binnen chroot) volledig doorlopen"
