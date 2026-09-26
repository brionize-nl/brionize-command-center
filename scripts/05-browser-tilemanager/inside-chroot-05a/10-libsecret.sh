#!/bin/bash
# BLFS 12.4 — libsecret-0.21.7. Draait binnen chroot, als root.
# Required: GLib (03b). Nodig voor WebKitGTK (credential-opslag).
# '-D gtk_doc=false' — boek-standaard, geen documentatietools gebouwd.
# NB: runtime hoort hier gnome-keyring bij (boek: "Required Runtime
# Dependency") — niet gebouwd, geen wachtwoordkluis-backend dus nog;
# dit blokkeert de BUILD niet, alleen een toekomstige runtime-feature.
set -euo pipefail
cd /sources
tar -xf libsecret-0.21.7.tar.xz
cd libsecret-0.21.7

mkdir bld
cd bld

meson setup --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    ..
ninja
ninja install

cd /sources
rm -rf libsecret-0.21.7
echo "==> libsecret klaar"
