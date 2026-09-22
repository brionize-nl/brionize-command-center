#!/bin/bash
# BLFS 12.4 — GObject-Introspection-1.84.0. Draait binnen chroot, als root.
# Stap 2/3 van de GLib-bootstrap (zie 07-glib-stage1.sh). Instructies
# staan letterlijk IN GLib's eigen BLFS-paginatekst (geen aparte pagina)
# als "Additional Downloads" + vervolgstappen. Bouwt tegen de zojuist
# in stap 1 geïnstalleerde (introspectie-loze) GLib.
set -euo pipefail
cd /sources/glib-2.84.4
tar -xf ../gobject-introspection-1.84.0.tar.xz

meson setup gobject-introspection-1.84.0 gi-build \
  --prefix=/usr --buildtype=release
ninja -C gi-build
ninja -C gi-build install

echo "==> GObject-Introspection klaar"
