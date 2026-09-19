#!/bin/bash
# LFS 12.4 hoofdstuk 8.54 — Wheel-0.46.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf wheel-0.46.1.tar.gz
cd wheel-0.46.1

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist wheel

cd /sources
rm -rf wheel-0.46.1
echo "==> Wheel klaar"
