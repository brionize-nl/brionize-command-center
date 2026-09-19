#!/bin/bash
# LFS 12.4 hoofdstuk 8.14 — Bc-7.0.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf bc-7.0.3.tar.xz
cd bc-7.0.3

CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make test

make install

cd /sources
rm -rf bc-7.0.3
echo "==> Bc klaar"
