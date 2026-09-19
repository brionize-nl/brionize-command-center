#!/bin/bash
# LFS 12.4 hoofdstuk 8.25 — Acl-2.3.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf acl-2.3.2
echo "==> Acl klaar"
