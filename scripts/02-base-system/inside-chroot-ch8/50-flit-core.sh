#!/bin/bash
# LFS 12.4 hoofdstuk 8.52 — Flit-Core-3.12.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf flit_core-3.12.0.tar.gz
cd flit_core-3.12.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist flit_core

cd /sources
rm -rf flit_core-3.12.0
echo "==> Flit-Core klaar"
