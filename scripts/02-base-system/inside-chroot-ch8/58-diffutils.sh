#!/bin/bash
# LFS 12.4 hoofdstuk 8.60 — Diffutils-3.12. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf diffutils-3.12.tar.xz
cd diffutils-3.12

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf diffutils-3.12
echo "==> Diffutils klaar"
