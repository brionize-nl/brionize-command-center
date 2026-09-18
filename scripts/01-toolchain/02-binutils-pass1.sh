#!/bin/bash
# LFS 12.4 — Binutils-2.45 Pass 1 (hoofdstuk 5). Draait als lfs-gebruiker.
source "$(dirname "$0")/env.sh"

cd "$LFS/sources"
tar -xf binutils-2.45.tar.xz
cd binutils-2.45

mkdir -v build
cd build

../configure --prefix="$LFS/tools" \
             --with-sysroot="$LFS" \
             --target="$LFS_TGT"   \
             --disable-nls         \
             --enable-gprofng=no   \
             --disable-werror      \
             --enable-new-dtags    \
             --enable-default-hash-style=gnu

make
make install

cd "$LFS/sources"
rm -rf binutils-2.45

echo "==> Binutils Pass 1 klaar"
