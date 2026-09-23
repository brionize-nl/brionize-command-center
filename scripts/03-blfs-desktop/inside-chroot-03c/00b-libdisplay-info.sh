#!/bin/bash
# BLFS 12.4 — libdisplay-info-0.3.0. Draait binnen chroot, als root.
# Required: hwdata (vorige stap). Nodig voor libxfce4windowing.
set -euo pipefail
cd /sources
tar -xf libdisplay-info-0.3.0.tar.xz
cd libdisplay-info-0.3.0

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libdisplay-info-0.3.0
echo "==> libdisplay-info klaar"
