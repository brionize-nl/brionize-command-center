#!/bin/bash
# BLFS 12.4 — Gdk-Pixbuf-2.42.12. Draait binnen chroot, als root.
# Required: GLib, libjpeg-turbo, libpng, shared-mime-info — allemaal al
# aanwezig. '-D others=enabled' bouwt de ingebouwde formaat-loaders
# (tga/pnm/etc.) — niet de externe-lib-afhankelijke loaders
# (avif/jxl/webp), die bewust niet meegenomen zijn (alleen "Optional
# runtime dependency").
set -euo pipefail
cd /sources
tar -xf gdk-pixbuf-2.42.12.tar.xz
cd gdk-pixbuf-2.42.12

mkdir build
cd build

meson setup ..            \
    --prefix=/usr       \
    --buildtype=release \
    -D others=enabled   \
    --wrap-mode=nofallback
ninja
ninja install

cd /sources
rm -rf gdk-pixbuf-2.42.12
echo "==> Gdk-Pixbuf klaar"
