#!/bin/bash
# LFS 12.4 hoofdstuk 8.9 — Lz4-1.10.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

make BUILD_STATIC=no PREFIX=/usr

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make -j1 check

make BUILD_STATIC=no PREFIX=/usr install

cd /sources
rm -rf lz4-1.10.0
echo "==> Lz4 klaar"
