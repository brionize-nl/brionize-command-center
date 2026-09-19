#!/bin/bash
# LFS 12.4 hoofdstuk 8.50 — Libffi-3.5.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf libffi-3.5.2.tar.gz
cd libffi-3.5.2

./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf libffi-3.5.2
echo "==> Libffi klaar"
