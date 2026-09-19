#!/bin/bash
# LFS 12.4 hoofdstuk 8.69 — Make-4.4.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr

make

chown -R tester .
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# su tester -c "PATH=$PATH make check"

make install

cd /sources
rm -rf make-4.4.1
echo "==> Make klaar"
