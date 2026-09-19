#!/bin/bash
# LFS 12.4 hoofdstuk 8.32 — Psmisc-23.7. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf psmisc-23.7.tar.xz
cd psmisc-23.7

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf psmisc-23.7
echo "==> Psmisc klaar"
