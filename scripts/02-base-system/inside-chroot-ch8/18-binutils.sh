#!/bin/bash
# LFS 12.4 hoofdstuk 8.20 — Binutils-2.45. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf binutils-2.45.tar.xz
cd binutils-2.45

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make tooldir=/usr

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make -k check

# grep geeft status 1 terug wanneer er (terecht) geen FAIL-regels zijn.
# set +e
# grep '^FAIL:' $(find -name '*.log')
# grep_status=$?
# set -e
# if (( grep_status > 1 )); then exit "$grep_status"; fi
# unset grep_status

make tooldir=/usr install

rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

cd /sources
rm -rf binutils-2.45
echo "==> Binutils klaar"
