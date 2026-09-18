#!/bin/bash
# LFS 12.4 — Bash-5.3 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host="$LFS_TGT"                   \
            --without-bash-malloc

make
make DESTDIR="$LFS" install
ln -sv bash "$LFS/bin/sh"

cd "$LFS/sources"
rm -rf bash-5.3
echo "==> Bash klaar"
