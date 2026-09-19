#!/bin/bash
# LFS 12.4 hoofdstuk 8.17 — Expect-5.45.4. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf expect5.45.4.tar.gz
cd expect5.45.4

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

patch -Np1 -i ../expect-5.45.4-gcc15-1.patch

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make test

make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd /sources
rm -rf expect5.45.4
echo "==> Expect klaar"
