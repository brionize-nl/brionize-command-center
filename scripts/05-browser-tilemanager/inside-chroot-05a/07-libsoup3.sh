#!/bin/bash
# BLFS 12.4 — libsoup3-3.6.5. Draait binnen chroot, als root. Required:
# glib-networking, libpsl, libxml2 (03b), nghttp2 — allemaal aanwezig
# na de vorige stappen. Nodig voor WebKitGTK (HTTP-laag).
#
# '-D tests=false' — GEEN boek-standaard, maar noodzakelijk gevolg van
# onze eigen '--without-p11-kit'-keuze bij GnuTLS (zie 03-gnutls.sh):
# vierde CI-run (2026-09-26) faalde bij het linken van libsoup3's eigen
# testsuite (`tests/ssl-test`) met "undefined reference to
# gnutls_pkcs11_init/gnutls_pkcs11_add_provider" — libsoup3's
# `pkcs11_tests`-optie staat op 'auto' en detecteert GnuTLS als
# aanwezig, maar niet dat het zonder PKCS11-support gebouwd is. Wij
# draaien libsoup3's testsuite hier sowieso niet (puur een
# WebKitGTK-afhankelijkheid, geen los ontwikkeldoel), dus alle
# unit-tests uitschakelen is de juiste, begrensde keuze — geen
# functionaliteit van de daadwerkelijke libsoup3-library verdwijnt.
set -euo pipefail
cd /sources
tar -xf libsoup-3.6.5.tar.xz
cd libsoup-3.6.5

sed 's/apiversion/soup_version/' -i docs/reference/meson.build

mkdir build
cd build

meson setup --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    -D tests=false          \
    ..
ninja
ninja install

cd /sources
rm -rf libsoup-3.6.5
echo "==> libsoup3 klaar"
