#!/bin/bash
# BLFS 12.4 — GnuTLS-3.8.10. Draait binnen chroot, als root. Required:
# Nettle + libtasn1 (beide vorige stappen — libtasn1 is een harde
# configure-vereiste, geen optionele "Recommended": eerste CI-run
# (2026-09-26) faalde hier expliciet met "Libtasn1 4.9 was not found"
# omdat libtasn1 toen nog NA GnuTLS in de volgorde stond; root-cause
# fix was herordenen, niet een configure-vlag). Nodig voor
# glib-networking (TLS-backend voor libsoup3, uiteindelijk voor
# WebKitGTK). Recommended (p11-kit, libunistring) bewust niet gebouwd.
set -euo pipefail
cd /sources
tar -xf gnutls-3.8.10.tar.xz
cd gnutls-3.8.10

./configure --prefix=/usr \
    --docdir=/usr/share/doc/gnutls-3.8.10 \
    --with-default-trust-store-pkcs11="pkcs11:"
make
make install

cd /sources
rm -rf gnutls-3.8.10
echo "==> GnuTLS klaar"
