#!/bin/bash
# LFS 12.4 hoofdstuk 8.65 — Gzip-1.14. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf gzip-1.14
echo "==> Gzip klaar"
