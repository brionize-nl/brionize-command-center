#!/bin/bash
# LFS 12.4 hoofdstuk 7.11 — Texinfo-7.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf texinfo-7.2.tar.xz
cd texinfo-7.2

./configure --prefix=/usr
make
make install

cd /sources
rm -rf texinfo-7.2
echo "==> Texinfo klaar"
