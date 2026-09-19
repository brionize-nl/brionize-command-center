#!/bin/bash
# LFS 12.4 hoofdstuk 8.42 — Less-679. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf less-679.tar.gz
cd less-679

./configure --prefix=/usr --sysconfdir=/etc

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf less-679
echo "==> Less klaar"
