#!/bin/bash
# BLFS 12.4 — CMake-4.1.0. Draait binnen chroot, als root.
# Nodig voor libjpeg-turbo (en later LLVM). Geen harde dependencies
# buiten wat al aanwezig is — bundelt jsoncpp/cppdap/librhash intern
# via --no-system-*.
set -euo pipefail
cd /sources
tar -xf cmake-4.1.0.tar.gz
cd cmake-4.1.0

sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
./bootstrap --prefix=/usr        \
    --system-libs        \
    --mandir=/share/man  \
    --no-system-jsoncpp  \
    --no-system-cppdap   \
    --no-system-librhash \
    --docdir=/share/doc/cmake-4.1.0
make
make install

cd /sources
rm -rf cmake-4.1.0
echo "==> CMake klaar"
