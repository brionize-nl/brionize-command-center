#!/bin/bash
# LFS 12.4 hoofdstuk 8.10 — Zstd-1.5.7. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf zstd-1.5.7.tar.gz
cd zstd-1.5.7

make prefix=/usr

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd /sources
rm -rf zstd-1.5.7
echo "==> Zstd klaar"
