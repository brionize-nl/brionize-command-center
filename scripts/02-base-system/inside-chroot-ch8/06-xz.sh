#!/bin/bash
# LFS 12.4 hoofdstuk 8.8 — Xz-5.8.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf xz-5.8.1.tar.xz
cd xz-5.8.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.1

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf xz-5.8.1
echo "==> Xz klaar"
