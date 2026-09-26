#!/bin/bash
# BLFS 12.4 — libsoup3-3.6.5. Draait binnen chroot, als root. Required:
# glib-networking, libpsl, libxml2 (03b), nghttp2 — allemaal aanwezig
# na de vorige stappen. Nodig voor WebKitGTK (HTTP-laag).
set -euo pipefail
cd /sources
tar -xf libsoup-3.6.5.tar.xz
cd libsoup-3.6.5

sed 's/apiversion/soup_version/' -i docs/reference/meson.build

mkdir build
cd build

meson setup --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    ..
ninja
ninja install

cd /sources
rm -rf libsoup-3.6.5
echo "==> libsoup3 klaar"
