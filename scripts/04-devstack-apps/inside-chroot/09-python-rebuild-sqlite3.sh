#!/bin/bash
# Python-3.13.7 — HERBOUW. Draait binnen chroot, als root. Letterlijk
# uit SQLite's eigen BLFS-pagina: "Several packages use an sqlite
# Python plugin. After installing this package, Python-3.13.7 should
# be rebuilt to create this plugin." Python (hoofdstuk 8) werd gebouwd
# vóórdat SQLite bestond, dus zonder het ingebouwde `_sqlite3`-
# extensiemodule — die wordt nu automatisch gedetecteerd en gebouwd nu
# SQLite (vorige stap) aanwezig is. Zelfde configure-vlaggen als de
# oorspronkelijke hoofdstuk-8-build (49-python.sh), voor consistentie.
#
# De Python-3.13.7-tarball staat al in /sources sinds hoofdstuk 8
# (fetch_verified() haalt niets dubbel op) — hier alleen opnieuw
# uitgepakt/herbouwd, niet opnieuw gefetcht.
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
make install

cd /sources
rm -rf Python-3.13.7

python3 -c "import sqlite3; print('sqlite3-module:', sqlite3.sqlite_version)"
echo "==> Python-herbouw (met sqlite3-module) klaar"
