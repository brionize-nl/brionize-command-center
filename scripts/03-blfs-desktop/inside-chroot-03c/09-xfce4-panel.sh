#!/bin/bash
# BLFS 12.4 — xfce4-panel-4.20.5. Draait binnen chroot, als root.
# Required: Cairo (uit 03b), Exo, Garcon, libwnck, libxfce4windowing —
# allemaal al aanwezig.
set -euo pipefail
cd /sources
tar -xf xfce4-panel-4.20.5.tar.bz2
cd xfce4-panel-4.20.5

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf xfce4-panel-4.20.5
echo "==> xfce4-panel klaar"
