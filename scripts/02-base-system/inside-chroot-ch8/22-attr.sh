#!/bin/bash
# LFS 12.4 hoofdstuk 8.24 — Attr-2.5.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf attr-2.5.2.tar.gz
cd attr-2.5.2

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf attr-2.5.2
echo "==> Attr klaar"
