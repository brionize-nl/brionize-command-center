#!/bin/bash
# LFS 12.4 hoofdstuk 8.39 — Gperf-3.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gperf-3.3.tar.gz
cd gperf-3.3

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf gperf-3.3
echo "==> Gperf klaar"
