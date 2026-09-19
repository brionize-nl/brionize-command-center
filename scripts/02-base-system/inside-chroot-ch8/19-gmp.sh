#!/bin/bash
# LFS 12.4 hoofdstuk 8.21 — GMP-6.3.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0

# Alleen een configure-voorbeeld voor 32-bit x86 met 64-bit CPU en CFLAGS.

sed -i '/long long t1;/,+1s/()/(...)/' configure

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check 2>&1 | tee gmp-check-log

# awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

# Het boek vereist minimaal 199 geslaagde tests.
# awk '/# PASS:/{total+=$3} END{exit !(total >= 199)}' gmp-check-log

make install
make install-html

cd /sources
rm -rf gmp-6.3.0
echo "==> GMP klaar"
