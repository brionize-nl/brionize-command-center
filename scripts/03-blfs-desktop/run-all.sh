#!/bin/bash
# Orchestreert fase 3 (BLFS 12.4 — Xorg + XFCE-desktop). Draait als root,
# in een VERSE container (losse 'docker run' t.o.v. hoofdstuk 8, dus de
# virtuele kernel-bestandssystemen moeten hier opnieuw gemount worden).
# Zie BLUEPRINT.md "Vast bouwpatroon per fase": checkpoints per sub-fase
# vanaf het begin, niet pas achteraf toevoegen.
#
# Env-vars (per sub-fase een eigen SKIP-vlag, zodat een cache-checkpoint
# op elke sub-fasegrens mogelijk is):
#   SKIP_XORG=true — sla 03a (Xorg-basisbibliotheken + server) over.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"
SKIP_XORG="${SKIP_XORG:-false}"
# Zelfde behoudende waarde als fase 2 (zie BLUEPRINT.md "Vast bouwpatroon
# per fase") — geen reden om terug te veranderen zonder concrete aanleiding.
CHROOT_MAKE_JOBS="2"

echo "==> Fase 3: virtuele kernel-bestandssystemen (opnieuw, verse container)"
bash "$(dirname "$SCRIPT_DIR")/02-base-system/ch7-02-mount-kernfs.sh"

if [ "$SKIP_XORG" = "true" ]; then
  echo "==> SKIP_XORG=true: 03a (Xorg) overgeslagen (cache-checkpoint hergebruikt)"
else
  echo "==> Fase 3 / 03a: Xorg-basisbibliotheken + server — bronnen ophalen (buiten chroot, als root)"
  bash "$SCRIPT_DIR/03a-00-fetch-sources.sh"

  echo "==> Scripts voor 03a zichtbaar maken binnen de chroot"
  mkdir -pv "$LFS/opt/lfs-scripts-03a"
  mount --bind "$SCRIPT_DIR/inside-chroot-03a" "$LFS/opt/lfs-scripts-03a"

  echo "==> 03a binnen chroot uitvoeren"
  if chroot "$LFS" /usr/bin/env -i \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin \
      MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
      TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
      /bin/bash /opt/lfs-scripts-03a/run-all.sh 2>&1 | tee "$LOG_DIR/log-03a-inside-chroot.txt"; then
    echo "==> 03a (binnen chroot) geslaagd"
  else
    echo "==> 03a (binnen chroot) MISLUKT — zie $LOG_DIR/log-03a-inside-chroot.txt"
    exit 1
  fi
fi

echo "==> Fase 3 (03a) volledig doorlopen"
