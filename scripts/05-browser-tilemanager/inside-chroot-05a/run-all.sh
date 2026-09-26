#!/bin/bash
# Orchestreert fase 5a (WebKitGTK-browserengine + volledige
# afhankelijkheidsketen). Draait binnen chroot, als root. Volgorde +
# onderbouwing: zie BLUEPRINT.md "Fase 5a — WebKitGTK-afhankelijkheids-
# keten".
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-nettle.sh"
  "02-gnutls.sh"
  "03-glib-networking.sh"
  "04-libpsl.sh"
  "05-nghttp2.sh"
  "06-libsoup3.sh"
  "07-icu.sh"
  "08-lcms2.sh"
  "09-libsecret.sh"
  "10-libtasn1.sh"
  "11-libwebp.sh"
  "12-openjpeg.sh"
  "13-ruby.sh"
  "14-unifdef.sh"
  "15-which.sh"
  "16-gstreamer.sh"
  "17-gst-plugins-base.sh"
  "18-gst-plugins-bad.sh"
  "19-webkitgtk.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 05a) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-05a-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-05a-$step.txt"
    exit 1
  fi
done

echo "==> Fase 5a (binnen chroot) volledig doorlopen"
