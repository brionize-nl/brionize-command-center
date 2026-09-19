#!/bin/bash
# LFS 12.4 hoofdstuk 8.37 — Libtool-2.5.4. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf libtool-2.5.4.tar.xz
cd libtool-2.5.4

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

rm -fv /usr/lib/libltdl.a

cd /sources
rm -rf libtool-2.5.4
echo "==> Libtool klaar"
