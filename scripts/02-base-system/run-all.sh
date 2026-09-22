#!/bin/bash
# Orchestreert fase 2 (LFS 12.4 hoofdstuk 6: temporary tools, hoofdstuk 7:
# chroot binnengaan + laatste temporary tools + cleanup, en hoofdstuk 8:
# het volledige basissysteem, ~80 pakketten). Draait als root. Vereist dat
# fase 1 (scripts/01-toolchain/run-all.sh) al in dezelfde container/
# $LFS-volume is doorlopen, TENZIJ SKIP_BOOTSTRAP=true (zie hieronder).
# Vereist --privileged (of minimaal CAP_SYS_ADMIN) i.v.m. mount/chroot.
#
# Env-vars voor de bootstrap-cache (zie BLUEPRINT.md "CI-strategie"):
#   SKIP_BOOTSTRAP=true  — sla hoofdstuk 6 en de hoofdstuk-7-pakketten over
#                          (worden al herbruikt uit een cache-checkpoint);
#                          hoofdstuk 7's chown/mount-stappen draaien altijd
#                          opnieuw (container-lokaal, niet cachebaar), en
#                          daarna gaat het gewoon door naar hoofdstuk 8.
#   SKIP_CH8=true         — stop na hoofdstuk 7, vóór hoofdstuk 8 begint
#                          (gebruikt om een schoon cache-checkpoint te maken
#                          precies op de fasegrens, vóór hoofdstuk 8 het
#                          $LFS-volume verder aanpast).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LFS=/mnt/lfs
LOG_DIR="$LFS/sources"
SKIP_BOOTSTRAP="${SKIP_BOOTSTRAP:-false}"
SKIP_CH8="${SKIP_CH8:-false}"
# Was eerder op 2 gezet uit voorzorg (vermoeden van een -j$(nproc)/OOM-
# oorzaak bij een GCC-rebuild-crash, run 35439085621). Die aanname bleek
# achteraf ONJUIST — de echte oorzaak was een losse `chown -R tester .`-regel
# in 11 hoofdstuk-8-scripts die een niet-bestaande testsuite-gebruiker
# aansprak (zie PROGRESS.md). Terug naar -j4 (de CI-runner heeft 4 cores) nu
# er geen bewijs meer is dat parallelliteit zelf het probleem was; als dit
# alsnog problemen geeft, is dat dan een nieuw, apart te onderzoeken feit.
CHROOT_MAKE_JOBS="4"

if [ "$SKIP_BOOTSTRAP" = "true" ]; then
  echo "==> SKIP_BOOTSTRAP=true: hoofdstuk 6 en de hoofdstuk-7-pakketten overgeslagen (cache-checkpoint hergebruikt)"
else
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
fi

echo "==> Fase 2 / Hoofdstuk 7: chroot voorbereiden (als root — altijd, ook bij SKIP_BOOTSTRAP)"
bash "$SCRIPT_DIR/ch7-01-changing-owner.sh"
bash "$SCRIPT_DIR/ch7-02-mount-kernfs.sh"

if [ "$SKIP_BOOTSTRAP" = "true" ]; then
  echo "==> Hoofdstuk-7-pakketten overgeslagen (cache-checkpoint hergebruikt)"
else
  echo "==> Scripts zichtbaar maken binnen de chroot"
  mkdir -pv "$LFS/opt/lfs-scripts"
  mount --bind "$SCRIPT_DIR/inside-chroot" "$LFS/opt/lfs-scripts"

  echo "==> Hoofdstuk 7 binnen chroot uitvoeren"
  if chroot "$LFS" /usr/bin/env -i \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin \
      MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
      TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
      /bin/bash /opt/lfs-scripts/run-inside-chroot.sh 2>&1 | tee "$LOG_DIR/log-ch7-inside-chroot.txt"; then
    echo "==> Hoofdstuk 7 (binnen chroot) geslaagd"
  else
    echo "==> Hoofdstuk 7 (binnen chroot) MISLUKT — zie $LOG_DIR/log-ch7-inside-chroot.txt"
    exit 1
  fi
fi

if [ "$SKIP_CH8" = "true" ]; then
  echo "==> SKIP_CH8=true: stoppen ná hoofdstuk 7 (cache-checkpoint-moment) — hoofdstuk 8 draait in een latere stap"
  exit 0
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
    MAKEFLAGS="-j$CHROOT_MAKE_JOBS" \
    TESTSUITEFLAGS="-j$CHROOT_MAKE_JOBS" \
    /bin/bash /opt/lfs-scripts-ch8/run-all.sh 2>&1 | tee "$LOG_DIR/log-ch8-inside-chroot.txt"; then
  echo "==> Hoofdstuk 8 (binnen chroot) geslaagd"
else
  echo "==> Hoofdstuk 8 (binnen chroot) MISLUKT — zie $LOG_DIR/log-ch8-inside-chroot.txt"
  exit 1
fi

echo "==> Fase 2 (hoofdstuk 6 + 7 + 8) volledig doorlopen"
