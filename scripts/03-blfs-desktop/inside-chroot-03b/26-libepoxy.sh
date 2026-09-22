#!/bin/bash
# BLFS 12.4 — libepoxy-1.5.10. Draait binnen chroot, als root.
# Required: Mesa (vorige stap). Nodig voor GTK3.
set -euo pipefail
cd /sources
tar -xf libepoxy-1.5.10.tar.xz
cd libepoxy-1.5.10

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libepoxy-1.5.10
echo "==> libepoxy klaar"
