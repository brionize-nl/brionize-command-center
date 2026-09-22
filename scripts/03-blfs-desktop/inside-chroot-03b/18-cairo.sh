#!/bin/bash
# BLFS 12.4 — Cairo-1.18.4. Draait binnen chroot, als root.
# Required: libpng, Pixman (uit 03a). Recommended: Fontconfig
# (herbouwd), GLib, Xorg Libraries (uit 03a) — allemaal al aanwezig.
# Boek-note over een circulaire relatie met HarfBuzz ("indien Cairo
# vóór HarfBuzz gebouwd wordt, Cairo herbouwen na HarfBuzz om Pango te
# kunnen bouwen") is hier niet van toepassing: HarfBuzz (stap 14) is
# hier al vóór Cairo gebouwd, dus geen aparte Cairo-herbouw nodig.
set -euo pipefail
cd /sources
tar -xf cairo-1.18.4.tar.xz
cd cairo-1.18.4

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf cairo-1.18.4
echo "==> Cairo klaar"
