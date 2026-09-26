#!/bin/bash
# BLFS 12.4 — nghttp2-1.66.0. Draait binnen chroot, als root. Alleen
# de hoofdbibliotheek nodig (--enable-lib-only, boek-standaard) —
# libxml2 (Recommended, al aanwezig) niet vereist voor de kale lib.
# Nodig voor libsoup3.
set -euo pipefail
cd /sources
tar -xf nghttp2-1.66.0.tar.xz
cd nghttp2-1.66.0

./configure --prefix=/usr     \
    --disable-static  \
    --enable-lib-only \
    --docdir=/usr/share/doc/nghttp2-1.66.0
make
make install

cd /sources
rm -rf nghttp2-1.66.0
echo "==> nghttp2 klaar"
