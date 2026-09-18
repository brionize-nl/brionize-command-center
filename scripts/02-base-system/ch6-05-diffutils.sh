#!/bin/bash
# LFS 12.4 — Diffutils-3.12 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf diffutils-3.12.tar.xz
cd diffutils-3.12

./configure --prefix=/usr   \
            --host="$LFS_TGT" \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)

make
make DESTDIR="$LFS" install

cd "$LFS/sources"
rm -rf diffutils-3.12
echo "==> Diffutils klaar"
