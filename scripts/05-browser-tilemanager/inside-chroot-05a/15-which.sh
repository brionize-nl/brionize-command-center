#!/bin/bash
# BLFS 12.4 — Which-2.23. Draait binnen chroot, als root. Geen
# dependencies. Nodig voor WebKitGTK's buildsysteem.
set -euo pipefail
cd /sources
tar -xf which-2.23.tar.gz
cd which-2.23

./configure --prefix=/usr
make
make install

cd /sources
rm -rf which-2.23
echo "==> Which klaar"
