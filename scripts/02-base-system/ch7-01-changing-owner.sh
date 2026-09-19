#!/bin/bash
# LFS 12.4 hoofdstuk 7.2 — Changing Owner. Draait als root, buiten chroot.
#
# Draait ook (via SKIP_BOOTSTRAP) nog een keer in de losse hoofdstuk-8-stap,
# ná hoofdstuk 7's eigen cleanup — op dat moment bestaat $LFS/tools al niet
# meer (bewust verwijderd, zie inside-chroot/08-cleanup.sh). Daarom per pad
# los chown'en i.p.v. één brace-expansion die faalt zodra één pad ontbreekt.
set -euo pipefail
export LFS=/mnt/lfs

for d in usr var etc tools; do
  [ -e "$LFS/$d" ] && chown --from lfs -R root:root "$LFS/$d"
done
case $(uname -m) in
  x86_64) [ -e "$LFS/lib64" ] && chown --from lfs -R root:root "$LFS/lib64" ;;
esac

echo "==> Eigenaarschap overgezet naar root"
