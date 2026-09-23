#!/bin/bash
# BLFS 12.4 — libxfce4windowing-4.20.4. Draait binnen chroot, als root.
# Required: GTK3, libdisplay-info (stap 00b), libwnck, xfce4-dev-tools
# — allemaal al aanwezig. '--enable-x11' (boek default) — we hebben
# geen Wayland, dus geen '--enable-wayland' nodig/mogelijk.
set -euo pipefail
cd /sources
tar -xf libxfce4windowing-4.20.4.tar.bz2
cd libxfce4windowing-4.20.4

./configure --prefix=/usr     \
    --sysconfdir=/etc \
    --enable-x11      \
    --disable-debug
make
make install

cd /sources
rm -rf libxfce4windowing-4.20.4
echo "==> libxfce4windowing klaar"
