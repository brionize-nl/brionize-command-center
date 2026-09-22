#!/bin/bash
# BLFS 12.4 — Mako-1.3.10 (Python-module). Draait binnen chroot, als root.
# Nodig voor Mesa. pip3-wheel-patroon uit BLFS' "Python Modules"-pagina
# (pip/wheel/setuptools/flit-core al aanwezig sinds hoofdstuk 8).
# NB: de tarball heet "mako" (kleine letter), installeert als "Mako".
set -euo pipefail
cd /sources
tar -xf mako-1.3.10.tar.gz
cd mako-1.3.10

pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD"
pip3 install --no-index --find-links dist --no-user Mako

cd /sources
rm -rf mako-1.3.10
echo "==> Mako klaar"
