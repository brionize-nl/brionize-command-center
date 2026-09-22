#!/bin/bash
# BLFS 12.4 — Fontconfig-2.17.1. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: libXft (onderdeel van de x7lib-lus,
# 08-x7lib-loop.sh) vereist naast FreeType (07a) ook Fontconfig. Testsuite
# overgeslagen (heeft internettoegang nodig, past niet bij CI). Documentatie
# overgeslagen via --disable-docs (boek levert de pre-generated docs toch
# niet standaard mee zonder DocBook-utils/texlive, die we niet bouwen).
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
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
echo "==> Fontconfig klaar"
