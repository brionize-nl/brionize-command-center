#!/bin/bash
# BLFS 12.4 — libjpeg-turbo-3.0.1. Draait binnen chroot, als root.
# Required: CMake (vorige stap). Nodig voor gdk-pixbuf.
set -euo pipefail
cd /sources
tar -xf libjpeg-turbo-3.0.1.tar.gz
cd libjpeg-turbo-3.0.1

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=RELEASE         \
    -D ENABLE_STATIC=FALSE              \
    -D CMAKE_INSTALL_DEFAULT_LIBDIR=lib \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -D CMAKE_SKIP_INSTALL_RPATH=ON      \
    -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/libjpeg-turbo-3.0.1 \
    ..
make
make install

cd /sources
rm -rf libjpeg-turbo-3.0.1
echo "==> libjpeg-turbo klaar"
