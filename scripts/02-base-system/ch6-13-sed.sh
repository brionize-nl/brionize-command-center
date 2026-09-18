#!/bin/bash
# LFS 12.4 — Sed-4.9 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr   \
            --host="$LFS_TGT" \
            --build=$(./build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf sed-4.9
echo "==> Sed klaar"
