#!/bin/bash
# BLFS 12.4 — libxfce4ui-4.20.2. Draait binnen chroot, als root.
# Required: GTK3 (uit 03b), Xfconf (vorige stap). Aanbevolen:
# startup-notification (al gebouwd, stap 00d).
set -euo pipefail
cd /sources
tar -xf libxfce4ui-4.20.2.tar.bz2
cd libxfce4ui-4.20.2

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf libxfce4ui-4.20.2
echo "==> libxfce4ui klaar"
