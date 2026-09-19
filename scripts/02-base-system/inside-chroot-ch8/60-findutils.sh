#!/bin/bash
# LFS 12.4 hoofdstuk 8.62 — Findutils-4.10.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf findutils-4.10.0.tar.xz
cd findutils-4.10.0

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid
# ('tester'-gebruiker bestaat daarom niet, dus ook de chown ervoor overgeslagen).
# chown -R tester .
# su tester -c "PATH=$PATH make check"

make install

cd /sources
rm -rf findutils-4.10.0
echo "==> Findutils klaar"
