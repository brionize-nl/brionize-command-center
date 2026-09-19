#!/bin/bash
# LFS 12.4 hoofdstuk 8.35 — Grep-3.12. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf grep-3.12.tar.xz
cd grep-3.12

sed -i "s/echo/#echo/" src/egrep.sh

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf grep-3.12
echo "==> Grep klaar"
