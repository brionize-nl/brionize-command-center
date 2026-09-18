#!/bin/bash
# LFS 12.4 hoofdstuk 7.7 — Gettext-0.26. Draait binnen chroot, als root.
# Alleen drie programma's worden geïnstalleerd (tijdelijke tool).
set -euo pipefail
cd /sources
tar -xf gettext-0.26.tar.xz
cd gettext-0.26

./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf gettext-0.26
echo "==> Gettext klaar"
