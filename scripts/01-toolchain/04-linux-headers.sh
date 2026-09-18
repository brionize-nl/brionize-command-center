#!/bin/bash
# LFS 12.4 — Linux-6.16.1 API Headers (hoofdstuk 5). Draait als lfs-gebruiker.
source "$(dirname "$0")/env.sh"

cd "$LFS/sources"
tar -xf linux-6.16.1.tar.xz
cd linux-6.16.1

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include "$LFS/usr"

cd "$LFS/sources"
rm -rf linux-6.16.1

echo "==> Linux API Headers klaar"
