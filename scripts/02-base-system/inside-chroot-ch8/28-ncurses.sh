#!/bin/bash
# LFS 12.4 hoofdstuk 8.30 — Ncurses-6.5-20250809. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf ncurses-6.5-20250809.tgz
cd ncurses-6.5-20250809

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

make

make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so

cp -v -R doc -T /usr/share/doc/ncurses-6.5-20250809

# Optionele ABI 5 voor vooraf gebouwde programma’s; niet nodig voor deze bronbuild.

cd /sources
rm -rf ncurses-6.5-20250809
echo "==> Ncurses klaar"
