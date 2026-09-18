#!/bin/bash
# LFS 12.4 — Coreutils-9.7 (hoofdstuk 6). Draait als lfs-gebruiker.
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf coreutils-9.7.tar.xz
cd coreutils-9.7

./configure --prefix=/usr                     \
            --host="$LFS_TGT"                  \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR="$LFS" install

mv -v "$LFS/usr/bin/chroot"              "$LFS/usr/sbin"
mkdir -pv "$LFS/usr/share/man/man8"
mv -v "$LFS/usr/share/man/man1/chroot.1" "$LFS/usr/share/man/man8/chroot.8"
sed -i 's/"1"/"8"/'                      "$LFS/usr/share/man/man8/chroot.8"

cd "$LFS/sources"
rm -rf coreutils-9.7
echo "==> Coreutils klaar"
