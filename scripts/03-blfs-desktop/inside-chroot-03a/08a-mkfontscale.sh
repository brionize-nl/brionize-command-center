#!/bin/bash
# BLFS 12.4 — mkfontscale-1.2.3. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: encodings (onderdeel van de
# x7font-lus, 09-x7font-loop.sh) vereist het mkfontscale-commando:
# "configure: error: mkfontscale is required to build encodings."
# Losstaand uit de x7app.html-batch (33 pakketten) getrokken — die batch
# heeft als aggregate "Required" o.a. Mesa (waarschijnlijk voor xdriinfo),
# wat de bewuste Mesa/glamor-vrije keuze bij xorg-server zou doorbreken.
# We bouwen hier alleen mkfontscale zelf (levert ook mkfontdir, uit
# dezelfde tarball). De rest van x7app.html volgt eventueel later, apart.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf mkfontscale-1.2.3.tar.xz
cd mkfontscale-1.2.3

./configure $XORG_CONFIG
make
make install

cd /sources
rm -rf mkfontscale-1.2.3
echo "==> mkfontscale klaar"
