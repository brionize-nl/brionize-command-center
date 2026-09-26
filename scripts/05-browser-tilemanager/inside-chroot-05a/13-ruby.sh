#!/bin/bash
# BLFS 12.4 — Ruby-3.4.5. Draait binnen chroot, als root. Required:
# libyaml (al aanwezig sinds fase 3b, voor PyYAML). Nodig voor
# WebKitGTK's eigen buildsysteem-scripts.
set -euo pipefail
cd /sources
tar -xf ruby-3.4.5.tar.xz
cd ruby-3.4.5

./configure --prefix=/usr         \
    --disable-rpath       \
    --enable-shared       \
    --without-valgrind    \
    --without-baseruby    \
    ac_cv_func_qsort_r=no \
    --docdir=/usr/share/doc/ruby-3.4.5
make
make install

cd /sources
rm -rf ruby-3.4.5
echo "==> Ruby klaar: $(ruby --version)"
