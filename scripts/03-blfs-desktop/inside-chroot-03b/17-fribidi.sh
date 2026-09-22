#!/bin/bash
# BLFS 12.4 — FriBidi-1.0.16. Draait binnen chroot, als root.
# Geen dependencies buiten wat al aanwezig is. Nodig voor Pango.
set -euo pipefail
cd /sources
tar -xf fribidi-1.0.16.tar.xz
cd fribidi-1.0.16

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf fribidi-1.0.16
echo "==> FriBidi klaar"
