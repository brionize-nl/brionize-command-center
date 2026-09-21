#!/bin/bash
# Orchestreert fase 3a (BLFS 12.4 — Xorg-basisbibliotheken + server).
# Draait binnen chroot, als root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-util-macros.sh"
  "02-xorgproto.sh"
  "03-libXau.sh"
  "04-libXdmcp.sh"
  "05-xcb-proto.sh"
  "06-libxcb.sh"
  "07-xcb-util.sh"
  "07a-freetype.sh"
  "08-x7lib-loop.sh"
  "09-x7font-loop.sh"
  "10-libxcvt.sh"
  "11-pixman.sh"
  "12-xkeyboard-config.sh"
  "13-xorg-server.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 03a) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-03a-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-03a-$step.txt"
    exit 1
  fi
done

echo "==> Fase 3a (binnen chroot) volledig doorlopen"
