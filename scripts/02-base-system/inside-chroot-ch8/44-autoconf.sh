#!/bin/bash
# LFS 12.4 hoofdstuk 8.46 — Autoconf-2.72. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf autoconf-2.72.tar.xz
cd autoconf-2.72

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf autoconf-2.72
echo "==> Autoconf klaar"
