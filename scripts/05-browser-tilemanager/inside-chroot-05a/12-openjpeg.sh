#!/bin/bash
# BLFS 12.4 — OpenJPEG-2.5.3. Draait binnen chroot, als root. Required:
# CMake (uit 03b). Nodig voor WebKitGTK (JPEG-2000).
set -euo pipefail
cd /sources
tar -xf openjpeg-2.5.3.tar.gz
cd openjpeg-2.5.3

mkdir -v build
cd build

cmake -D CMAKE_BUILD_TYPE=Release  \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_STATIC_LIBS=OFF ..
make
make install
cp -rv ../doc/man -T /usr/share/man

cd /sources
rm -rf openjpeg-2.5.3
echo "==> OpenJPEG klaar"
