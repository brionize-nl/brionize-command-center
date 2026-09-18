#!/bin/bash
# Orchestreert fase 1 (LFS hoofdstuk 4.2/4.3 + hoofdstuk 5) binnen de
# wegwerp-Docker-sandbox. Draait als root (nodig voor user/dir-setup);
# de daadwerkelijke pakket-builds draaien als de onbevoorrechte
# 'lfs'-gebruiker, exact zoals het officiële boek voorschrijft.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/mnt/lfs/sources"

echo "==> Fase 1: host & directory-layout voorbereiden"
bash "$SCRIPT_DIR/00-prepare-host.sh"

STEPS=(
  "01-fetch-sources.sh"
  "02-binutils-pass1.sh"
  "03-gcc-pass1.sh"
  "04-linux-headers.sh"
  "05-glibc.sh"
  "06-libstdcpp-pass1.sh"
)

for step in "${STEPS[@]}"; do
  echo "==> ---- $step ----"
  # su -c i.p.v. su - lfs -c: bewust GEEN login-shell/.bash_profile-keten,
  # want elk script sourcet zelf env.sh (headless-automatisering, geen
  # interactieve terminal zoals het boek veronderstelt).
  if su lfs -c "bash '$SCRIPT_DIR/$step'" 2>&1 | tee "$LOG_DIR/log-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-$step.txt"
    exit 1
  fi
done

echo "==> Fase 1 (toolchain) volledig doorlopen"
