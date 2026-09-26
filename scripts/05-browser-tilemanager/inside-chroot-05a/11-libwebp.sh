#!/bin/bash
# BLFS 12.4 — libwebp-1.6.0. Draait binnen chroot, als root.
# Recommended-deps (libjpeg-turbo/libpng/libtiff/SDL2) bewust niet
# meegenomen behalve libjpeg-turbo/libpng die we al hebben (geen
# nieuwe flags nodig, configure detecteert ze zelf indien aanwezig).
# Nodig voor WebKitGTK (WebP-afbeeldingsformaat).
set -euo pipefail
cd /sources
tar -xf libwebp-1.6.0.tar.gz
cd libwebp-1.6.0

./configure --prefix=/usr           \
    --enable-libwebpmux     \
    --enable-libwebpdemux   \
    --enable-libwebpdecoder \
    --enable-libwebpextras  \
    --enable-swap-16bit-csp \
    --disable-static
make
make install

cd /sources
rm -rf libwebp-1.6.0
echo "==> libwebp klaar"
