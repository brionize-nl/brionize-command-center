#!/bin/bash
# LFS 12.4 — Xz-5.8.1 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf xz-5.8.1.tar.xz
cd xz-5.8.1

./configure --prefix=/usr                     \
            --host="$LFS_TGT"                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.1

make
make DESTDIR="$LFS" install
rm -v "$LFS/usr/lib/liblzma.la"

cd "$LFS/sources"
rm -rf xz-5.8.1
echo "==> Xz klaar"
