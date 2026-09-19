#!/bin/bash
# LFS 12.4 hoofdstuk 8.82 — SysVinit-3.14. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf sysvinit-3.14.tar.xz
cd sysvinit-3.14

patch -Np1 -i ../sysvinit-3.14-consolidated-1.patch

make

make install

cd /sources
rm -rf sysvinit-3.14
echo "==> SysVinit klaar"
