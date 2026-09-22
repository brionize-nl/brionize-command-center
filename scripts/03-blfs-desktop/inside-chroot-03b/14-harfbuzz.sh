#!/bin/bash
# BLFS 12.4 — HarfBuzz-11.4.1. Draait binnen chroot, als root.
# Recommended: GLib (aanwezig), FreeType (aanwezig uit 03a, nog zonder
# HarfBuzz-ondersteuning — voor déze eerste HarfBuzz-build geen
# probleem). '-D graphite2=disabled' — Graphite2 bewust niet gebouwd
# (alleen nodig voor texlive/LibreOffice-integratie, niet voor ons).
set -euo pipefail
cd /sources
tar -xf harfbuzz-11.4.1.tar.xz
cd harfbuzz-11.4.1

mkdir build
cd build

meson setup ..             \
    --prefix=/usr        \
    --buildtype=release  \
    -D graphite2=disabled
ninja
ninja install

cd /sources
rm -rf harfbuzz-11.4.1
echo "==> HarfBuzz klaar"
