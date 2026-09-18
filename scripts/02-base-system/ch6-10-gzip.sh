#!/bin/bash
# LFS 12.4 — Gzip-1.14 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr --host="$LFS_TGT"

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf gzip-1.14
echo "==> Gzip klaar"
