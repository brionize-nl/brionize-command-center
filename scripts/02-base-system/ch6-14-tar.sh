#!/bin/bash
# LFS 12.4 — Tar-1.35 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf tar-1.35.tar.xz
cd tar-1.35

./configure --prefix=/usr --host="$LFS_TGT" --build=$(build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf tar-1.35
echo "==> Tar klaar"
