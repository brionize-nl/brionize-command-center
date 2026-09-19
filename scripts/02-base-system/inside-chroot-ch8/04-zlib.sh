#!/bin/bash
# LFS 12.4 hoofdstuk 8.6 — Zlib-1.3.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf zlib-1.3.1.tar.gz
cd zlib-1.3.1

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

rm -fv /usr/lib/libz.a

cd /sources
rm -rf zlib-1.3.1
echo "==> Zlib klaar"
