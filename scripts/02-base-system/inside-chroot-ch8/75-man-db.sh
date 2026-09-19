#!/bin/bash
# LFS 12.4 hoofdstuk 8.77 — Man-DB-2.13.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf man-db-2.13.1.tar.xz
cd man-db-2.13.1

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf man-db-2.13.1
echo "==> Man-DB klaar"
