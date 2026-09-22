#!/bin/bash
# BLFS 12.4 — Fontconfig-2.17.1, HERBOUW. Draait binnen chroot, als root.
# Letterlijk uit Pango's eigen BLFS-Required-regel: "must be built with
# FreeType using HarfBuzz" — linkt nu tegen de zojuist herbouwde,
# HarfBuzz-bewuste FreeType (vorige stap). Zelfde bouwstappen als de
# eerste keer in 03a (07b-fontconfig.sh); de tarball staat al in
# /sources.
set -euo pipefail
cd /sources
tar -xf fontconfig-2.17.1.tar.xz
cd fontconfig-2.17.1

./configure --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-docs       \
    --docdir=/usr/share/doc/fontconfig-2.17.1
make
make install

cd /sources
rm -rf fontconfig-2.17.1
echo "==> Fontconfig-herbouw (met HarfBuzz-bewuste FreeType) klaar"
