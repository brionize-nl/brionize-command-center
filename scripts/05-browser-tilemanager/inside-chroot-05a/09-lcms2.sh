#!/bin/bash
# BLFS 12.4 — Little CMS2-2.17. Draait binnen chroot, als root. Geen
# harde dependencies. Nodig voor WebKitGTK (kleurbeheer).
set -euo pipefail
cd /sources
tar -xf lcms2-2.17.tar.gz
cd lcms2-2.17

./configure --prefix=/usr --disable-static
make
make install

cd /sources
rm -rf lcms2-2.17
echo "==> Little CMS2 klaar"
