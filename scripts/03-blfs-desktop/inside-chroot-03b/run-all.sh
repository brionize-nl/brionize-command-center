#!/bin/bash
# Orchestreert fase 3b (BLFS 12.4 — GTK3-supporting-stack). Draait
# binnen chroot, als root. Volgorde + onderbouwing: zie BLUEPRINT.md
# "Fase 3b — GTK3-supporting-stack: volledige bouwvolgorde".
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "01-pcre2.sh"
  "02-libpng.sh"
  "03-libyaml.sh"
  "04-mako.sh"
  "05-cython.sh"
  "06-pyyaml.sh"
  "07-glib-stage1.sh"
  "08-gobject-introspection.sh"
  "09-glib-stage2.sh"
  "10-libxml2.sh"
  "11-shared-mime-info.sh"
  "12-dbus.sh"
  "13-gsettings-desktop-schemas.sh"
  "14-harfbuzz.sh"
  "15-freetype-rebuild.sh"
  "16-fontconfig-rebuild.sh"
  "17-fribidi.sh"
  "18-cairo.sh"
  "19-pango.sh"
  "20-cmake.sh"
  "21-libjpeg-turbo.sh"
  "22-gdk-pixbuf.sh"
  "23-at-spi2-core.sh"
  "24-llvm.sh"
  "25-mesa.sh"
  "26-libepoxy.sh"
  "27-gtk3.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot 03b) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-03b-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-03b-$step.txt"
    exit 1
  fi
done

echo "==> Fase 3b (binnen chroot) volledig doorlopen"
