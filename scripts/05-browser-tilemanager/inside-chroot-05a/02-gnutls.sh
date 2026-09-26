#!/bin/bash
# BLFS 12.4 — GnuTLS-3.8.10. Draait binnen chroot, als root. Required:
# Nettle (vorige stap). Nodig voor glib-networking (TLS-backend voor
# libsoup3, uiteindelijk voor WebKitGTK). Recommended (p11-kit,
# libunistring) bewust niet gebouwd — boek zelf: als libtasn1
# ontbreekt gebruikt GnuTLS zijn eigen ingebakken kopie; wij bouwen
# libtasn1 sowieso apart (WebKitGTK's eigen Required-lijst).
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
