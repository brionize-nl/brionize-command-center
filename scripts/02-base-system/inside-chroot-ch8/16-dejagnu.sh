#!/bin/bash
# LFS 12.4 hoofdstuk 8.18 — DejaGNU-1.6.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cd /sources
rm -rf dejagnu-1.6.3
echo "==> DejaGNU klaar"
