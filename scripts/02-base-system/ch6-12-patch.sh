#!/bin/bash
# LFS 12.4 — Patch-2.8 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf patch-2.8.tar.xz
cd patch-2.8

./configure --prefix=/usr   \
            --host="$LFS_TGT" \
            --build=$(build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf patch-2.8
echo "==> Patch klaar"
