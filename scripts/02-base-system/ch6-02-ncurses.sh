#!/bin/bash
# LFS 12.4 — Ncurses-6.5-20250809 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf ncurses-6.5-20250809.tgz
cd ncurses-6.5-20250809

mkdir build
pushd build
  ../configure --prefix="$LFS/tools" AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic "$LFS/tools/bin"
popd

./configure --prefix=/usr                \
            --host="$LFS_TGT"             \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

make
make DESTDIR="$LFS" install

ln -sv libncursesw.so "$LFS/usr/lib/libncurses.so"
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i "$LFS/usr/include/curses.h"

cd "$LFS/sources"
rm -rf ncurses-6.5-20250809
echo "==> Ncurses klaar"
