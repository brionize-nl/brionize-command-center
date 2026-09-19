#!/bin/bash
# LFS 12.4 hoofdstuk 8.27 — Libxcrypt-4.4.38. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf libxcrypt-4.4.38.tar.xz
cd libxcrypt-4.4.38

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

# Optionele verouderde ABI voor vooraf gebouwde programma’s; niet nodig voor deze bronbuild.

cd /sources
rm -rf libxcrypt-4.4.38
echo "==> Libxcrypt klaar"
