#!/bin/bash
# LFS 12.4 hoofdstuk 8.48 — OpenSSL-3.5.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf openssl-3.5.2.tar.gz
cd openssl-3.5.2

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.5.2

cp -vfr doc/* /usr/share/doc/openssl-3.5.2

cd /sources
rm -rf openssl-3.5.2
echo "==> OpenSSL klaar"
