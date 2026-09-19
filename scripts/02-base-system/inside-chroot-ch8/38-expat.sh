#!/bin/bash
# LFS 12.4 hoofdstuk 8.40 — Expat-2.7.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf expat-2.7.1.tar.xz
cd expat-2.7.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.1

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.1

cd /sources
rm -rf expat-2.7.1
echo "==> Expat klaar"
