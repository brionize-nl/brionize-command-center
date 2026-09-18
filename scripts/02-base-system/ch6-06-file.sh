#!/bin/bash
# LFS 12.4 — File-5.46 (hoofdstuk 6). Draait als lfs-gebruiker.
# Wordt twee keer gebouwd: een native host-tool (voor gebruik tijdens de
# cross-build zelf) en de cross-gecompileerde versie voor $LFS.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf file-5.46.tar.gz
cd file-5.46

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host="$LFS_TGT" --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR="$LFS" install
rm -v "$LFS/usr/lib/libmagic.la"

cd "$LFS/sources"
rm -rf file-5.46
echo "==> File klaar"
