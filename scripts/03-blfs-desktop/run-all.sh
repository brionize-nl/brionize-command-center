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
#   SKIP_GTK3_STACK=true — sla 03b (GTK3-supporting-stack) over.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"
SKIP_XORG="${SKIP_XORG:-false}"
SKIP_GTK3_STACK="${SKIP_GTK3_STACK:-false}"
# Zelfde -j4 als fase 2 nu (zie 02-base-system/run-all.sh) — de eerdere
# -j2-voorzichtigheid bleek gebaseerd op een verkeerde oorzaakaanname.
CHROOT_MAKE_JOBS="4"

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

if [ "$SKIP_GTK3_STACK" = "true" ]; then
  echo "==> SKIP_GTK3_STACK=true: 03b (GTK3-supporting-stack) overgeslagen (cache-checkpoint hergebruikt)"
else
  echo "==> Fase 3 / 03b: GTK3-supporting-stack — bronnen ophalen (buiten chroot, als root)"
  bash "$SCRIPT_DIR/03b-00-fetch-sources.sh"

  echo "==> Scripts voor 03b zichtbaar maken binnen de chroot"
  mkdir -pv "$LFS/opt/lfs-scripts-03b"
  mount --bind "$SCRIPT_DIR/inside-chroot-03b" "$LFS/opt/lfs-scripts-03b"

  echo "==> 03b binnen chroot uitvoeren"
  if chroot "$LFS" /usr/bin/env -i \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin \
      MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
      TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
      /bin/bash /opt/lfs-scripts-03b/run-all.sh 2>&1 | tee "$LOG_DIR/log-03b-inside-chroot.txt"; then
    echo "==> 03b (binnen chroot) geslaagd"
  else
    echo "==> 03b (binnen chroot) MISLUKT — zie $LOG_DIR/log-03b-inside-chroot.txt"
    exit 1
  fi
fi

echo "==> Fase 3 (03a + 03b) volledig doorlopen"
