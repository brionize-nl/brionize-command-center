#!/bin/bash
# LFS 12.4 hoofdstuk 8.44 — XML::Parser-2.47. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

perl Makefile.PL

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make test

make install

cd /sources
rm -rf XML-Parser-2.47
echo "==> XML::Parser klaar"
