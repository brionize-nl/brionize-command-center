#!/bin/bash
# BLFS 12.4 — Shared-Mime-Info-2.4. Draait binnen chroot, als root.
# Nodig voor gdk-pixbuf (Required: GLib + libxml2, beide al aanwezig).
set -euo pipefail
cd /sources
tar -xf shared-mime-info-2.4.tar.gz
cd shared-mime-info-2.4

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release -D update-mimedb=true ..
ninja
ninja install

cd /sources
rm -rf shared-mime-info-2.4
echo "==> Shared-Mime-Info klaar"
