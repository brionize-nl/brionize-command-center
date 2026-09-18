#!/bin/bash
# Orchestreert LFS 12.4 hoofdstuk 7 (temporary tools binnen chroot).
# Wordt aangeroepen via 'chroot $LFS /usr/bin/env -i ... /bin/bash
# /opt/lfs-scripts/run-inside-chroot.sh' — draait dus al met de juiste
# root-omgeving (env -i + PATH=/usr/bin:/usr/sbin, geen extra sourcing
# nodig).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/sources"

STEPS=(
  "00-creating-dirs.sh"
  "01-creating-files.sh"
  "02-gettext.sh"
  "03-bison.sh"
  "04-perl.sh"
  "05-python.sh"
  "06-texinfo.sh"
  "07-util-linux.sh"
  "08-cleanup.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- (chroot) $step ----"
  if bash "$SCRIPT_DIR/$step" 2>&1 | tee "$LOG_DIR/log-chroot-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-chroot-$step.txt"
    exit 1
  fi
done

echo "==> Hoofdstuk 7 (binnen chroot) volledig doorlopen"
