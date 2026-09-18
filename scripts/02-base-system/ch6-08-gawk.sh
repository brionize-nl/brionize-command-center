#!/bin/bash
# LFS 12.4 — Gawk-5.3.2 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf gawk-5.3.2.tar.xz
cd gawk-5.3.2

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host="$LFS_TGT" \
            --build=$(build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf gawk-5.3.2
echo "==> Gawk klaar"
