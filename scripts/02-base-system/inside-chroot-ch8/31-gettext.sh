#!/bin/bash
# LFS 12.4 hoofdstuk 8.33 — Gettext-0.26. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gettext-0.26.tar.xz
cd gettext-0.26

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.26

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd /sources
rm -rf gettext-0.26
echo "==> Gettext klaar"
