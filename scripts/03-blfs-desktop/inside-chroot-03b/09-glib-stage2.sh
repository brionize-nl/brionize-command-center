#!/bin/bash
# BLFS 12.4 — GLib-2.84.4, stap 3/3. Draait binnen chroot, als root.
# Laatste stap van de GLib-bootstrap: nu GObject-Introspection aanwezig
# is (stap 2), introspectie alsnog inschakelen, herbouwen en opnieuw
# installeren (genereert nu de introspectiedata van GLib's eigen
# bibliotheken — nodig voor XFCE-core, dat "GLib met GObject
# Introspection" als harde Required-dependency heeft).
set -euo pipefail
cd /sources/glib-2.84.4/build

meson configure -D introspection=enabled
ninja
ninja install

cd /sources
rm -rf glib-2.84.4
echo "==> GLib stap 3/3 (met introspectie) klaar"
