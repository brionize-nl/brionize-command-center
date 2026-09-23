#!/bin/bash
# BLFS 12.4 — iceauth-1.0.10. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: xfce4-session's eigen configure
# vereist het iceauth-commando ("iceauth missing, please check your X11
# installation") voor ICE-sessiebeheer. Losstaand uit de
# x7app.html-batch (33 pakketten, met als aggregate "Required" o.a.
# Mesa-25.1.8, waarschijnlijk voor xdriinfo) getrokken — zelfde bewuste
# aanpak als eerder bij mkfontscale (03a): niet de hele batch bouwen,
# alleen dit ene commando. Heeft zelf alleen libICE/libSM nodig, beide
# al aanwezig uit 03a's x7lib-lus.
set -euo pipefail
cd /sources
tar -xf iceauth-1.0.10.tar.xz
cd iceauth-1.0.10

./configure --prefix=/usr
make
make install

cd /sources
rm -rf iceauth-1.0.10
echo "==> iceauth klaar"
