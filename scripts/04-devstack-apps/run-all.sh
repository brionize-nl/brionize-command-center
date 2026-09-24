#!/bin/bash
# Orchestreert fase 4 (devstack: Node.js, Bun, gh, cloudflared,
# Supabase CLI, Tailscale, PostgreSQL, SQLite, n8n, PM2). Draait als
# root, in een VERSE container (losse 'docker run' t.o.v. fase 3, dus
# de virtuele kernel-bestandssystemen moeten hier opnieuw gemount
# worden — zelfde patroon als 03-blfs-desktop/run-all.sh).
#
# PWA-snelkoppelingen (Claude/ChatGPT/Mistral/Gemini) zijn BEWUST
# uitgesteld naar een eigen vervolgstap — vereisen een browser-engine
# die nog niet gebouwd is. Zie BLUEPRINT.md "Fase 4" voor de volledige
# onderbouwing en het aan Brionize voorgelegde besluit (2026-09-24).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"
# Zelfde -j4 als fase 2/3.
CHROOT_MAKE_JOBS="4"

echo "==> Fase 4: virtuele kernel-bestandssystemen (opnieuw, verse container)"
bash "$(dirname "$SCRIPT_DIR")/02-base-system/ch7-02-mount-kernfs.sh"

echo "==> Fase 4: bronnen ophalen (buiten chroot, als root)"
bash "$SCRIPT_DIR/00-fetch-sources.sh"

echo "==> Scripts voor fase 4 zichtbaar maken binnen de chroot"
mkdir -pv "$LFS/opt/lfs-scripts-04"
mount --bind "$SCRIPT_DIR/inside-chroot" "$LFS/opt/lfs-scripts-04"

echo "==> Fase 4 binnen chroot uitvoeren"
if chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/local/bin:/usr/bin:/usr/sbin \
    MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
    TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
    /bin/bash /opt/lfs-scripts-04/run-all.sh 2>&1 | tee "$LOG_DIR/log-04-inside-chroot.txt"; then
  echo "==> Fase 4 (binnen chroot) geslaagd"
else
  echo "==> Fase 4 (binnen chroot) MISLUKT — zie $LOG_DIR/log-04-inside-chroot.txt"
  exit 1
fi

echo "==> Fase 4 volledig doorlopen"
