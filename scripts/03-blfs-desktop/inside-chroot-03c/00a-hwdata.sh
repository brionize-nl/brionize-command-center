#!/bin/bash
# BLFS 12.4 — hwdata-0.398. Draait binnen chroot, als root.
# Nodig voor libdisplay-info. Geen dependencies.
set -euo pipefail
cd /sources
tar -xf hwdata-0.398.tar.gz
cd hwdata-0.398

./configure --prefix=/usr --disable-blacklist
make install

cd /sources
rm -rf hwdata-0.398
echo "==> hwdata klaar"
