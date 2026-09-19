#!/bin/bash
# LFS 12.4 hoofdstuk 8.49 — Libelf from Elfutils-0.193. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf elfutils-0.193.tar.bz2
cd elfutils-0.193

./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /sources
rm -rf elfutils-0.193
echo "==> Libelf (Elfutils) klaar"
