#!/bin/bash
# LFS 12.4 hoofdstuk 8.23 — MPC-1.3.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
make install-html

cd /sources
rm -rf mpc-1.3.1
echo "==> MPC klaar"
