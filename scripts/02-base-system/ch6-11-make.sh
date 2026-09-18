#!/bin/bash
# LFS 12.4 — Make-4.4.1 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr   \
            --host="$LFS_TGT" \
            --build=$(build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf make-4.4.1
echo "==> Make klaar"
