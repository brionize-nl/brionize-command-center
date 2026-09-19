#!/bin/bash
# LFS 12.4 hoofdstuk 8.78 — Procps-ng-4.0.5. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf procps-ng-4.0.5.tar.xz
cd procps-ng-4.0.5

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid
# ('tester'-gebruiker bestaat daarom niet, dus ook de chown ervoor overgeslagen).
# chown -R tester .
# su tester -c "PATH=$PATH make check"

make install

cd /sources
rm -rf procps-ng-4.0.5
echo "==> Procps-ng klaar"
