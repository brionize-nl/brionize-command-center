#!/bin/bash
# BLFS 12.4 — GLib-Networking-2.80.1. Draait binnen chroot, als root.
# Required: GLib (uit 03b), GnuTLS (vorige stap). Nodig voor libsoup3.
# '-D libproxy=disabled' (boek-standaard) — geen libproxy gebouwd.
set -euo pipefail
cd /sources
tar -xf glib-networking-2.80.1.tar.xz
cd glib-networking-2.80.1

mkdir build
cd build

meson setup             \
    --prefix=/usr        \
    --buildtype=release  \
    -D libproxy=disabled \
    ..
ninja
ninja install

cd /sources
rm -rf glib-networking-2.80.1
echo "==> GLib-Networking klaar"
