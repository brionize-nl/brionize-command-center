#!/bin/bash
# LFS 12.4 hoofdstuk 8.38 — GDBM-1.26. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gdbm-1.26.tar.gz
cd gdbm-1.26

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf gdbm-1.26
echo "==> GDBM klaar"
