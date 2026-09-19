#!/bin/bash
# LFS 12.4 hoofdstuk 8.11 — File-5.46. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf file-5.46.tar.gz
cd file-5.46

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf file-5.46
echo "==> File klaar"
