#!/bin/bash
# BLFS 12.4 — CMake-4.1.0. Draait binnen chroot, als root.
# Nodig voor libjpeg-turbo (en later LLVM).
#
# AFWIJKING t.o.v. het boek: GEEN '--system-libs'. Het boek's
# standaardcommando zet dit aan (met --no-system-jsoncpp/cppdap/librhash
# als uitzonderingen), wat CMake laat linken tegen systeem-cURL/
# libarchive/libuv/nghttp2 — allemaal alleen "Recommended" voor CMake,
# bewust niet gebouwd. Zonder de vlag bundelt CMake deze intern
# (inclusief cURL, dat anders "CMAKE_USE_SYSTEM_CURL is ON but a curl
# is not found!" geeft) — simpeler, geen extra pakketten nodig.
set -euo pipefail
cd /sources
tar -xf cmake-4.1.0.tar.gz
cd cmake-4.1.0

sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
./bootstrap --prefix=/usr        \
    --mandir=/share/man  \
    --docdir=/share/doc/cmake-4.1.0
make
make install

cd /sources
rm -rf cmake-4.1.0
echo "==> CMake klaar"
