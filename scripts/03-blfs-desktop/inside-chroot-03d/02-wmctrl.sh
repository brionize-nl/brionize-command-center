#!/bin/bash
# wmctrl-1.07. Draait binnen chroot, als root. Niet in BLFS — officiële
# broncode via Wayback Machine (oorspronkelijke site tripie.sweb.cz is
# dood). Standaard autotools-pakket, geen nieuwe dependencies (libX11/
# libXmu al aanwezig uit 03a).
set -euo pipefail
cd /sources
tar -xf wmctrl-1.07.tar
cd wmctrl-1.07

./configure --prefix=/usr
make
make install

cd /sources
rm -rf wmctrl-1.07
echo "==> wmctrl klaar"
