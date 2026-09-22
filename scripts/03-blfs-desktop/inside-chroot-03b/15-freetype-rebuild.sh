#!/bin/bash
# BLFS 12.4 — FreeType-2.13.3, HERBOUW. Draait binnen chroot, als root.
# Letterlijk uit HarfBuzz's eigen BLFS-Recommended-regel: "after
# harfbuzz is installed, reinstall freetype" — FreeType's configure
# detecteert HarfBuzz nu automatisch via pkgconfig en voegt
# subpixel-hinting-ondersteuning toe. Zelfde bouwstappen als de eerste
# keer in 03a (07a-freetype.sh); de tarball staat al in /sources.
set -euo pipefail
cd /sources
tar -xf freetype-2.13.3.tar.xz
cd freetype-2.13.3

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg
sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h

./configure --prefix=/usr --enable-freetype-config --disable-static
make
make install

cd /sources
rm -rf freetype-2.13.3
echo "==> FreeType-herbouw (met HarfBuzz) klaar"
