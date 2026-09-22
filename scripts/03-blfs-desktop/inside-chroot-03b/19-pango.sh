#!/bin/bash
# BLFS 12.4 — Pango-1.56.4. Draait binnen chroot, als root.
# Required: Fontconfig (herbouwd met HarfBuzz-bewuste FreeType),
# FriBidi, GLib. Recommended: Cairo (gebouwd na HarfBuzz — voldaan door
# de volgorde in deze fase). '-D introspection=enabled' — matcht onze
# GObject-Introspection-keuze bij GLib.
set -euo pipefail
cd /sources
tar -xf pango-1.56.4.tar.xz
cd pango-1.56.4

mkdir build
cd build

meson setup \
    --prefix=/usr            \
    --buildtype=release      \
    --wrap-mode=nofallback   \
    -D introspection=enabled \
    ..
ninja
ninja install

cd /sources
rm -rf pango-1.56.4
echo "==> Pango klaar"
