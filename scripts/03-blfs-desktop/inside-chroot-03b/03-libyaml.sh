#!/bin/bash
# BLFS 12.4 — libyaml (yaml-0.2.5). Draait binnen chroot, als root.
# Nodig voor de PyYAML-Python-module (op zijn beurt nodig voor Mesa).
set -euo pipefail
cd /sources
tar -xf yaml-0.2.5.tar.gz
cd yaml-0.2.5

./configure --prefix=/usr --disable-static
make
make install

cd /sources
rm -rf yaml-0.2.5
echo "==> libyaml klaar"
