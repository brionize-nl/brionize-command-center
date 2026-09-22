#!/bin/bash
# BLFS 12.4 — Cython-3.1.3 (Python-module). Draait binnen chroot, als root.
# Nodig voor de PyYAML-Python-module (op zijn beurt nodig voor Mesa).
set -euo pipefail
cd /sources
tar -xf cython-3.1.3.tar.gz
cd cython-3.1.3

pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD"
pip3 install --no-index --find-links dist --no-user Cython

cd /sources
rm -rf cython-3.1.3
echo "==> Cython klaar"
