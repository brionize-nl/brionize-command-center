#!/bin/bash
# BLFS 12.4 — Freetype-2.13.3. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: libXft (onderdeel van de x7lib-lus,
# 08-x7lib-loop.sh) vereist FreeType — die hoorde oorspronkelijk bij de
# GTK-stack (een latere fase-3-sub-fase) ingepland te worden, maar is dus
# al hier nodig. Geen documentatiepakket (freetype-doc) meegenomen —
# optioneel, niet nodig om te bouwen/linken.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
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
echo "==> Freetype klaar"
