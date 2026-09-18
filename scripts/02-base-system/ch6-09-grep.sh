#!/bin/bash
# LFS 12.4 — Grep-3.12 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf grep-3.12.tar.xz
cd grep-3.12

./configure --prefix=/usr --host="$LFS_TGT" --build=$(./build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf grep-3.12
echo "==> Grep klaar"
