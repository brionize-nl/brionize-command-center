#!/bin/bash
# BLFS 12.4 — libgudev-238. Draait binnen chroot, als root.
# Required: GLib (aanwezig uit 03b). Nodig voor thunar-volman.
set -euo pipefail
cd /sources
tar -xf libgudev-238.tar.xz
cd libgudev-238

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libgudev-238
echo "==> libgudev klaar"
