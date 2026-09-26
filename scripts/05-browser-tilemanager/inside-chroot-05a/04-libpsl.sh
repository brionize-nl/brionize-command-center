#!/bin/bash
# BLFS 12.4 — libpsl-0.21.5. Draait binnen chroot, als root. Geen
# harde Required-dependencies (libidn2/libunistring bewust niet
# gebouwd, alleen "Recommended"). Nodig voor libsoup3.
set -euo pipefail
cd /sources
tar -xf libpsl-0.21.5.tar.gz
cd libpsl-0.21.5

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libpsl-0.21.5
echo "==> libpsl klaar"
