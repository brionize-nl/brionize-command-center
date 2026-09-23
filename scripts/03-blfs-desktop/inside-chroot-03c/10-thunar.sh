#!/bin/bash
# BLFS 12.4 — Thunar-4.20.4. Draait binnen chroot, als root.
# Required: Exo (aanwezig). Required (runtime): hicolor-icon-theme
# (stap 00c). Aanbevolen: libgudev (00e), libnotify (00h), pcre2 (uit
# 03b). De boek-sed voorkomt het installeren van een systemd-user-unit
# (we hebben geen systemd).
set -euo pipefail
cd /sources
tar -xf thunar-4.20.4.tar.bz2
cd thunar-4.20.4

sed -i 's/\tinstall-systemd_userDATA/\t/' Makefile.in

./configure --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir=/usr/share/doc/thunar-4.20.4
make
make install

cd /sources
rm -rf thunar-4.20.4
echo "==> Thunar klaar"
