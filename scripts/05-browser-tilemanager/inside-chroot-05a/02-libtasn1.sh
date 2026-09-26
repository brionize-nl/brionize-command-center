#!/bin/bash
# BLFS 12.4 — libtasn1-4.20.0. Draait binnen chroot, als root. Geen
# harde dependencies. Vroeg in de keten gebouwd (vóór GnuTLS) omdat
# GnuTLS's eigen configure dit hard vereist (>=4.9, getest via
# pkg-config) en zonder systeem-libtasn1 hard faalt — geen automatische
# fallback naar een ingebakken kopie zoals eerder aangenomen (echte
# CI-log-evidence, zie PROGRESS.md 2026-09-26). Ook nodig voor
# WebKitGTK's eigen Required-vermelding — één gedeelde systeem-build
# voor beide, geen dubbel werk.
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
