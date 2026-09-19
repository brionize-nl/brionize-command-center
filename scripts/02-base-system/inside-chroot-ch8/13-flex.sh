#!/bin/bash
# LFS 12.4 hoofdstuk 8.15 — Flex-2.6.4. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd /sources
rm -rf flex-2.6.4
echo "==> Flex klaar"
