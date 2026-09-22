#!/bin/bash
# BLFS 12.4 — docutils-0.21.2 (Python-module). Draait binnen chroot, als
# root. Toegevoegd na een terugkerend patroon (Anti-Patch-Loop-regel):
# zowel GLib (07-glib-stage1.sh) als gdk-pixbuf (22-gdk-pixbuf.sh) faalden
# op "rst2man not found" zodra man-pages/documentatie stond op de
# boek-standaard (aan). In plaats van dit per pakket los te blijven
# tegenkomen en telkens een aparte -D man*=disabled-vlag te zoeken,
# hier vroeg in 03b docutils gebouwd (levert o.a. rst2man) — dit
# voorkomt dezelfde klasse fout bij latere pakketten (at-spi2-core,
# Mesa, GTK3) die nog niet getest zijn. De reeds gevonden losse
# man-pages=disabled-fixes bij GLib/gdk-pixbuf blijven staan (bewezen,
# geen reden om terug te draaien) — dit is een aanvulling, geen vervanging.
set -euo pipefail
cd /sources
tar -xf docutils-0.21.2.tar.gz
cd docutils-0.21.2

pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD"
pip3 install --no-index --find-links dist --no-user docutils

cd /sources
rm -rf docutils-0.21.2
echo "==> docutils klaar"
