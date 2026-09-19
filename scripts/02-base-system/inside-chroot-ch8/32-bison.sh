#!/bin/bash
# LFS 12.4 hoofdstuk 8.34 — Bison-3.8.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf bison-3.8.2
echo "==> Bison klaar"
