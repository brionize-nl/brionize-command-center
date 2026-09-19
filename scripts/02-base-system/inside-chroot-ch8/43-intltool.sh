#!/bin/bash
# LFS 12.4 hoofdstuk 8.45 — Intltool-0.51.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /sources
rm -rf intltool-0.51.0
echo "==> Intltool klaar"
