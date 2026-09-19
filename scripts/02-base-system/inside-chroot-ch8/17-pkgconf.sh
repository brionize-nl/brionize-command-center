#!/bin/bash
# LFS 12.4 hoofdstuk 8.19 — Pkgconf-2.5.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf pkgconf-2.5.1.tar.xz
cd pkgconf-2.5.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

make

make install

ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd /sources
rm -rf pkgconf-2.5.1
echo "==> Pkgconf klaar"
