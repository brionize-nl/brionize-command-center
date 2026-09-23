#!/bin/bash
# BLFS 12.4 — xfce4-dev-tools-4.20.0. Draait binnen chroot, als root.
# Required: GLib (aanwezig). Nodig voor libxfce4windowing.
set -euo pipefail
cd /sources
tar -xf xfce4-dev-tools-4.20.0.tar.bz2
cd xfce4-dev-tools-4.20.0

./configure --prefix=/usr
make
make install

cd /sources
rm -rf xfce4-dev-tools-4.20.0
echo "==> xfce4-dev-tools klaar"
