#!/bin/bash
# BLFS 12.4 — libpng-1.6.50. Draait binnen chroot, als root.
# Nodig voor Cairo en gdk-pixbuf. Geen apng-patch (optioneel, alleen
# nodig voor Firefox/Seamonkey/Thunderbird-compatibiliteit).
set -euo pipefail
cd /sources
tar -xf libpng-1.6.50.tar.xz
cd libpng-1.6.50

./configure --prefix=/usr --disable-static
make
make install

cd /sources
rm -rf libpng-1.6.50
echo "==> libpng klaar"
