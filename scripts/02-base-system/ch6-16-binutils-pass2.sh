#!/bin/bash
# LFS 12.4 — Binutils-2.45 Pass 2 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf binutils-2.45.tar.xz
cd binutils-2.45

sed '6031s/$add_dir//' -i ltmain.sh

mkdir -v build
cd build

../configure \
    --prefix=/usr \
    --build=$(../config.guess) \
    --host="$LFS_TGT" \
    --disable-nls \
    --enable-shared \
    --enable-gprofng=no \
    --disable-werror \
    --enable-64-bit-bfd \
    --enable-new-dtags \
    --enable-default-hash-style=gnu

make
make DESTDIR="$LFS" install
rm -v "$LFS"/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

cd "$LFS/sources"
rm -rf binutils-2.45
echo "==> Binutils Pass 2 klaar"
