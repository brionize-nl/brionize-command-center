#!/bin/bash
# BLFS 12.4 — PCRE2-10.45. Draait binnen chroot, als root.
# Los gebouwd i.p.v. GLib het zelf laten downloaden tijdens de build
# (GLib's "Recommended" downloadt anders zelf van internet — niet
# gewenst, alle downloads via fetch_verified()).
set -euo pipefail
cd /sources
tar -xf pcre2-10.45.tar.bz2
cd pcre2-10.45

./configure --prefix=/usr                       \
    --docdir=/usr/share/doc/pcre2-10.45 \
    --enable-unicode                    \
    --enable-jit                        \
    --enable-pcre2-16                   \
    --enable-pcre2-32                   \
    --enable-pcre2grep-libz             \
    --enable-pcre2grep-libbz2           \
    --enable-pcre2test-libreadline      \
    --disable-static
make
make install

cd /sources
rm -rf pcre2-10.45
echo "==> PCRE2 klaar"
