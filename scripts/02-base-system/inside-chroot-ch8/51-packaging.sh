#!/bin/bash
# LFS 12.4 hoofdstuk 8.53 — Packaging-25.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf packaging-25.0.tar.gz
cd packaging-25.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist packaging

cd /sources
rm -rf packaging-25.0
echo "==> Packaging klaar"
