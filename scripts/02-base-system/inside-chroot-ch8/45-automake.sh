#!/bin/bash
# LFS 12.4 hoofdstuk 8.47 — Automake-1.18.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf automake-1.18.1.tar.xz
cd automake-1.18.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make -j$(($(nproc)>4?$(nproc):4)) check

make install

cd /sources
rm -rf automake-1.18.1
echo "==> Automake klaar"
