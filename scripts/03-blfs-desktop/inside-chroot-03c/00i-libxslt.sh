#!/bin/bash
# BLFS 12.4 — libxslt-1.1.43. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: xfce4-dev-tools' eigen configure
# faalt hard op "package 'xsltproc' missing" — dit is, anders dan de
# eerdere rst2man/xsltproc-man-pages-issues bij GLib/gdk-pixbuf/GTK3
# (die via een -D man*=false-vlag te omzeilen waren), een HARDE,
# niet-optionele dependency van xfce4-dev-tools zelf. Required:
# libxml2 (aanwezig uit 03b).
set -euo pipefail
cd /sources
tar -xf libxslt-1.1.43.tar.xz
cd libxslt-1.1.43

./configure --prefix=/usr    \
    --disable-static \
    --docdir=/usr/share/doc/libxslt-1.1.43
make
make install

cd /sources
rm -rf libxslt-1.1.43
echo "==> libxslt klaar"
