#!/bin/bash
# LFS 12.4 hoofdstuk 8.71 — Tar-1.35. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf tar-1.35.tar.xz
cd tar-1.35

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd /sources
rm -rf tar-1.35
echo "==> Tar klaar"
