#!/bin/bash
# LFS 12.4 hoofdstuk 7.12 — Util-linux-2.41.1. Draait binnen chroot, als
# root.
set -euo pipefail
cd /sources
tar -xf util-linux-2.41.1.tar.xz
cd util-linux-2.41.1

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.1

make
make install

cd /sources
rm -rf util-linux-2.41.1
echo "==> Util-linux klaar — hoofdstuk 7 pakketten compleet"
