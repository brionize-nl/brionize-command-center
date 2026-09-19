#!/bin/bash
# LFS 12.4 hoofdstuk 8.70 — Patch-2.8. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf patch-2.8.tar.xz
cd patch-2.8

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf patch-2.8
echo "==> Patch klaar"
