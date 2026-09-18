#!/bin/bash
# LFS 12.4 — Libstdc++ Pass 1 (hoofdstuk 5, onderdeel van de GCC-bron).
# Draait als lfs-gebruiker. Het boek instrueert hier expliciet om de GCC-
# tarball opnieuw uit te pakken (los van de eerdere GCC Pass 1 extractie,
# die na installatie al is opgeruimd door 03-gcc-pass1.sh).
source "$(dirname "$0")/env.sh"

cd "$LFS/sources"
tar -xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

mkdir -v build
cd build

../libstdc++-v3/configure      \
    --host="$LFS_TGT"          \
    --build=$(../config.guess) \
    --prefix=/usr               \
    --disable-multilib          \
    --disable-nls               \
    --disable-libstdcxx-pch     \
    --with-gxx-include-dir=/tools/"$LFS_TGT"/include/c++/15.2.0

make
make DESTDIR="$LFS" install

rm -v "$LFS"/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd "$LFS/sources"
rm -rf gcc-15.2.0

echo "==> Libstdc++ Pass 1 klaar — fase 1 (toolchain) compleet"
