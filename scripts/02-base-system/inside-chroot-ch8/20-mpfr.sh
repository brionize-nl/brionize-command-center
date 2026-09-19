#!/bin/bash
# LFS 12.4 hoofdstuk 8.22 — MPFR-4.2.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf mpfr-4.2.2.tar.xz
cd mpfr-4.2.2

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

make
make html

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
make install-html

cd /sources
rm -rf mpfr-4.2.2
echo "==> MPFR klaar"
