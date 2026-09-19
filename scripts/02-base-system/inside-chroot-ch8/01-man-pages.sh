#!/bin/bash
# LFS 12.4 hoofdstuk 8.3 — Man-pages-6.15. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf man-pages-6.15.tar.xz
cd man-pages-6.15

rm -v man3/crypt*
make -R GIT=false prefix=/usr install

cd /sources
rm -rf man-pages-6.15
echo "==> Man-pages klaar"
