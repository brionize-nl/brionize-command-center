#!/bin/bash
# LFS 12.4 hoofdstuk 8.51 — Python-3.13.7. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf Python-3.13.7.tar.xz
cd Python-3.13.7

./configure --prefix=/usr          \
            --enable-shared        \
            --with-system-expat    \
            --enable-optimizations \
            --without-static-libpython

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make test TESTOPTS="--timeout 120"

make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF


install -v -dm755 /usr/share/doc/python-3.13.7/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.13.7/html \
    -xvf ../python-3.13.7-docs-html.tar.bz2

cd /sources
rm -rf Python-3.13.7
echo "==> Python klaar"
