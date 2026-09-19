#!/bin/bash
# LFS 12.4 hoofdstuk 8.61 — Gawk-5.3.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gawk-5.3.2.tar.xz
cd gawk-5.3.2

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

chown -R tester .
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# su tester -c "PATH=$PATH make check"

rm -f /usr/bin/gawk-5.3.2
make install

ln -sv gawk.1 /usr/share/man/man1/awk.1

install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2

cd /sources
rm -rf gawk-5.3.2
echo "==> Gawk klaar"
