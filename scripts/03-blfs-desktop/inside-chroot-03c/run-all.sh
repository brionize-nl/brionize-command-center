#!/bin/bash
# Orchestreert fase 3c (BLFS 12.4 — XFCE-core). Draait binnen chroot,
# als root. Volgorde + onderbouwing: zie BLUEPRINT.md "Dependency-audit
# fase 3b/3c" (XFCE-core-gedeelte).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "00a-hwdata.sh"
  "00b-libdisplay-info.sh"
  "00c-hicolor-icon-theme.sh"
  "00d-startup-notification.sh"
  "00e-libgudev.sh"
  "00f-desktop-file-utils.sh"
  "00g-lxde-icon-theme.sh"
  "00h-libnotify.sh"
  "00i-libxslt.sh"
  "01-libxfce4util.sh"
  "02-xfconf.sh"
  "03-libxfce4ui.sh"
  "04-exo.sh"
  "05-garcon.sh"
  "06-libwnck.sh"
  "07-xfce4-dev-tools.sh"
  "08-libxfce4windowing.sh"
  "09-xfce4-panel.sh"
  "10-thunar.sh"
  "11-thunar-volman.sh"
  "12-tumbler.sh"
  "13-xfce4-appfinder.sh"
  "14-xfce4-settings.sh"
  "15-xfdesktop.sh"
  "16-xfwm4.sh"
  "17-xfce4-session.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 03c) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-03c-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-03c-$step.txt"
    exit 1
  fi
done

echo "==> Fase 3c (binnen chroot) volledig doorlopen"
