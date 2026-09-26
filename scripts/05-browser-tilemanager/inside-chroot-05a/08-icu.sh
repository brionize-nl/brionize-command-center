#!/bin/bash
# BLFS 12.4 — ICU-77.1. Draait binnen chroot, als root. Geen
# dependencies buiten wat al aanwezig is. Nodig voor WebKitGTK
# (Unicode/globalisatie). Boek: "This package expands to the
# directory icu" (bevestigd via spot-download vóór het schrijven).
set -euo pipefail
cd /sources
tar -xf icu4c-77_1-src.tgz
cd icu/source

./configure --prefix=/usr
make
make install

cd /sources
rm -rf icu
echo "==> ICU klaar"
