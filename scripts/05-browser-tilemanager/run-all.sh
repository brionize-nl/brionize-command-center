#!/bin/bash
# Orchestreert fase 5 (browser-engine + tegel-manager). Draait als
# root, in een VERSE container (losse 'docker run' t.o.v. fase 4, dus
# de virtuele kernel-bestandssystemen moeten hier opnieuw gemount
# worden — zelfde patroon als 03-blfs-desktop/run-all.sh).
#
# Zie BLUEPRINT.md "UX-herziening: Tegel-manager & Visuele laag"
# (2026-09-26) voor de volledige specificatie. Sub-fasen:
#   05a — WebKitGTK-browserengine + volledige afhankelijkheidsketen.
#   05b — minimale WebKitGTK-kiosk-shell + generiek webapp-mechanisme
#         (nog te bouwen).
#   05c — tegel-manager-kern (nog te bouwen).
#
# Env-vars (per sub-fase een eigen SKIP-vlag, zelfde patroon als fase 3):
#   SKIP_WEBKIT=true — sla 05a (WebKitGTK) over.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"
SKIP_WEBKIT="${SKIP_WEBKIT:-false}"
# Zelfde -j4 als fase 2/3/4 — WebKitGTK zelf overschrijft dit lokaal
# in 19-webkitgtk.sh naar -j2 (boek-waarschuwing over geheugengebruik
# per compile-job, zie dat script).
CHROOT_MAKE_JOBS="4"

echo "==> Fase 5: virtuele kernel-bestandssystemen (opnieuw, verse container)"
bash "$(dirname "$SCRIPT_DIR")/02-base-system/ch7-02-mount-kernfs.sh"

if [ "$SKIP_WEBKIT" = "true" ]; then
  echo "==> SKIP_WEBKIT=true: 05a (WebKitGTK) overgeslagen (cache-checkpoint hergebruikt)"
else
  echo "==> Fase 5 / 05a: WebKitGTK-afhankelijkheidsketen — bronnen ophalen (buiten chroot, als root)"
  bash "$SCRIPT_DIR/05a-00-fetch-sources.sh"

  echo "==> Scripts voor 05a zichtbaar maken binnen de chroot"
  mkdir -pv "$LFS/opt/lfs-scripts-05a"
  mount --bind "$SCRIPT_DIR/inside-chroot-05a" "$LFS/opt/lfs-scripts-05a"

  echo "==> 05a binnen chroot uitvoeren"
  if chroot "$LFS" /usr/bin/env -i \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/local/bin:/usr/bin:/usr/sbin \
      MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
      TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
      /bin/bash /opt/lfs-scripts-05a/run-all.sh 2>&1 | tee "$LOG_DIR/log-05a-inside-chroot.txt"; then
    echo "==> 05a (binnen chroot) geslaagd"
  else
    echo "==> 05a (binnen chroot) MISLUKT — zie $LOG_DIR/log-05a-inside-chroot.txt"
    exit 1
  fi
fi

echo "==> Fase 5 (05a) volledig doorlopen"
