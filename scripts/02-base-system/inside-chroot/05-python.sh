#!/bin/bash
# LFS 12.4 hoofdstuk 7.10 — Python-3.13.7. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf Python-3.13.7.tar.xz
cd Python-3.13.7

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

make
make install

cd /sources
rm -rf Python-3.13.7
echo "==> Python klaar"
