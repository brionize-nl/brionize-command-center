#!/bin/bash
# LFS 12.4 hoofdstuk 7.2 — Changing Owner. Draait als root, buiten chroot.
set -euo pipefail
export LFS=/mnt/lfs

chown --from lfs -R root:root "$LFS"/{usr,var,etc,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root "$LFS/lib64" ;;
esac

echo "==> Eigenaarschap overgezet naar root"
