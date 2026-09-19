#!/bin/bash
# LFS 12.4 hoofdstuk 8.72 — Texinfo-7.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf texinfo-7.2.tar.xz
cd texinfo-7.2

sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm

./configure --prefix=/usr

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

make TEXMF=/usr/share/texmf install-tex

# Optionele reparatie van een beschadigde Info-index; niet nodig bij een nieuwe installatie.

cd /sources
rm -rf texinfo-7.2
echo "==> Texinfo klaar"
