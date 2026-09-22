#!/bin/bash
# BLFS 12.4 — GLib-2.84.4, stap 1/3. Draait binnen chroot, als root.
# GLib wordt bewust in drie stappen gebouwd (07/08/09) — letterlijk het
# boek's eigen bootstrap-patroon: GObject-Introspection heeft een
# geïnstalleerde GLib nodig om te bouwen, maar GLib's eigen
# introspectiedata heeft op zijn beurt GObject-Introspection nodig om
# gegenereerd te worden. Stap 1: GLib bouwen/installeren MET
# introspection nog uitgeschakeld.
#
# Extractiemap blijft bewaard (niet opgeruimd) — stap 2/3 bouwt in
# dezelfde broncode-/build-map verder.
#
# '-D man-pages=disabled' (boek default: enabled) — vereist anders
# rst2man (uit docutils, alleen "Recommended" voor GLib, bewust niet
# gebouwd) en faalt configure met "Program 'rst2man rst2man.py' not
# found". Geen man-pages nodig voor een werkend systeem.
set -euo pipefail
cd /sources
tar -xf glib-2.84.4.tar.xz
cd glib-2.84.4

mkdir build
cd build

meson setup ..                  \
  --prefix=/usr             \
  --buildtype=release       \
  -D introspection=disabled \
  -D glib_debug=disabled    \
  -D man-pages=disabled     \
  -D sysprof=disabled
ninja
ninja install

echo "==> GLib stap 1/3 (zonder introspectie) klaar"
