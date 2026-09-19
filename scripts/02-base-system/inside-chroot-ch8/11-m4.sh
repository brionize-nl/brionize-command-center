#!/bin/bash
# LFS 12.4 hoofdstuk 8.13 — M4-1.4.20. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf m4-1.4.20.tar.xz
cd m4-1.4.20

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf m4-1.4.20
echo "==> M4 klaar"
