#!/bin/bash
# LFS 12.4 hoofdstuk 8.63 — Groff-1.23.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf groff-1.23.0.tar.gz
cd groff-1.23.0

# Boekplaceholder <paper_size>: configureerbaar, standaard A4.

PAGE="${LFS_PAPER_SIZE:-A4}" ./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

cd /sources
rm -rf groff-1.23.0
echo "==> Groff klaar"
