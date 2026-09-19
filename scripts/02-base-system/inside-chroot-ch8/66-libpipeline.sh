#!/bin/bash
# LFS 12.4 hoofdstuk 8.68 — Libpipeline-1.5.8. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8

./configure --prefix=/usr

make

make install

cd /sources
rm -rf libpipeline-1.5.8
echo "==> Libpipeline klaar"
