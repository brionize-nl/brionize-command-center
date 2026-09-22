#!/bin/bash
# BLFS 12.4 — PyYAML-6.0.2 (Python-module). Draait binnen chroot, als root.
# Nodig voor Mesa (Required: Mako + PyYAML). Vereist zelf Cython +
# libyaml (beide al gebouwd in 03/05).
# NB: de tarball heet "pyyaml" (kleine letters), installeert als "PyYAML".
set -euo pipefail
cd /sources
tar -xf pyyaml-6.0.2.tar.gz
cd pyyaml-6.0.2

pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD"
pip3 install --no-index --find-links dist --no-user PyYAML

cd /sources
rm -rf pyyaml-6.0.2
echo "==> PyYAML klaar"
