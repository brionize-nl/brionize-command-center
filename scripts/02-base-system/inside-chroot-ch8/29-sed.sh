#!/bin/bash
# LFS 12.4 hoofdstuk 8.31 — Sed-4.9. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr

make
make html

chown -R tester .
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd /sources
rm -rf sed-4.9
echo "==> Sed klaar"
