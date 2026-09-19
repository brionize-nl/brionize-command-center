#!/bin/bash
# Orchestreert fase 2 (LFS 12.4 hoofdstuk 6: temporary tools, hoofdstuk 7:
# chroot binnengaan + laatste temporary tools + cleanup, en hoofdstuk 8:
# het volledige basissysteem, ~80 pakketten). Draait als root. Vereist dat
# fase 1 (scripts/01-toolchain/run-all.sh) al in dezelfde container/
# $LFS-volume is doorlopen (lfs-gebruiker + $LFS/tools bestaan al).
# Vereist --privileged (of minimaal CAP_SYS_ADMIN) i.v.m. mount/chroot.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"

echo "==> Fase 2 / Hoofdstuk 6: temporary tools (als lfs-gebruiker)"
CH6_STEPS=(
  "ch6-00-fetch-sources.sh"
  "ch6-01-m4.sh"
  "ch6-02-ncurses.sh"
  "ch6-03-bash.sh"
  "ch6-04-coreutils.sh"
  "ch6-05-diffutils.sh"
  "ch6-06-file.sh"
  "ch6-07-findutils.sh"
  "ch6-08-gawk.sh"
  "ch6-09-grep.sh"
  "ch6-10-gzip.sh"
  "ch6-11-make.sh"
  "ch6-12-patch.sh"
  "ch6-13-sed.sh"
  "ch6-14-tar.sh"
  "ch6-15-xz.sh"
  "ch6-16-binutils-pass2.sh"
  "ch6-17-gcc-pass2.sh"
)

for step in "${CH6_STEPS[@]}"; do
  echo "==> ---- $step ----"
  if su lfs -c "bash '$SCRIPT_DIR/$step'" 2>&1 | tee "$LOG_DIR/log-$step.txt"; then
    echo "==> $step geslaagd"
  else
    echo "==> $step MISLUKT — zie $LOG_DIR/log-$step.txt"
    exit 1
  fi
done

echo "==> Fase 2 / Hoofdstuk 7: chroot voorbereiden (als root)"
bash "$SCRIPT_DIR/ch7-01-changing-owner.sh"
bash "$SCRIPT_DIR/ch7-02-mount-kernfs.sh"

echo "==> Scripts zichtbaar maken binnen de chroot"
mkdir -pv "$LFS/opt/lfs-scripts"
mount --bind "$SCRIPT_DIR/inside-chroot" "$LFS/opt/lfs-scripts"

echo "==> Hoofdstuk 7 binnen chroot uitvoeren"
if chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="-j$(nproc)" \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash /opt/lfs-scripts/run-inside-chroot.sh 2>&1 | tee "$LOG_DIR/log-ch7-inside-chroot.txt"; then
  echo "==> Hoofdstuk 7 (binnen chroot) geslaagd"
else
  echo "==> Hoofdstuk 7 (binnen chroot) MISLUKT — zie $LOG_DIR/log-ch7-inside-chroot.txt"
  exit 1
fi

echo "==> Fase 2 / Hoofdstuk 8: volledige basissysteem — bronnen ophalen (buiten chroot, als root)"
bash "$SCRIPT_DIR/ch8-00-fetch-sources.sh"

echo "==> Scripts voor hoofdstuk 8 zichtbaar maken binnen de chroot"
mkdir -pv "$LFS/opt/lfs-scripts-ch8"
mount --bind "$SCRIPT_DIR/inside-chroot-ch8" "$LFS/opt/lfs-scripts-ch8"

echo "==> Hoofdstuk 8 binnen chroot uitvoeren"
if chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="-j$(nproc)" \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash /opt/lfs-scripts-ch8/run-all.sh 2>&1 | tee "$LOG_DIR/log-ch8-inside-chroot.txt"; then
  echo "==> Hoofdstuk 8 (binnen chroot) geslaagd"
else
  echo "==> Hoofdstuk 8 (binnen chroot) MISLUKT — zie $LOG_DIR/log-ch8-inside-chroot.txt"
  exit 1
fi

echo "==> Fase 2 (hoofdstuk 6 + 7 + 8) volledig doorlopen"
