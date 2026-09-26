#!/bin/bash
# BLFS 12.4 — libtasn1-4.20.0. Draait binnen chroot, als root. Geen
# harde dependencies. Nodig voor WebKitGTK direct, en voor GnuTLS
# (herbouwt GnuTLS niet — GnuTLS werd hiervoor al gebouwd met zijn
# eigen ingebakken libtasn1-kopie; deze systeem-libtasn1 is voor
# WebKitGTK's eigen Required-vermelding).
set -euo pipefail
cd /sources
tar -xf libtasn1-4.20.0.tar.gz
cd libtasn1-4.20.0

./configure --prefix=/usr --disable-static
make
make install

cd /sources
rm -rf libtasn1-4.20.0
echo "==> libtasn1 klaar"
