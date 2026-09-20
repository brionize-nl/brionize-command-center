#!/bin/bash
# BLFS 12.4 — Util-macros-1.20.2. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf util-macros-1.20.2.tar.xz
cd util-macros-1.20.2

./configure $XORG_CONFIG
make install

cd /sources
rm -rf util-macros-1.20.2
echo "==> Util-macros klaar"
