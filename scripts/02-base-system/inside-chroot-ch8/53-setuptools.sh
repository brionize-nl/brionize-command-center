#!/bin/bash
# LFS 12.4 hoofdstuk 8.55 — Setuptools-80.9.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf setuptools-80.9.0.tar.gz
cd setuptools-80.9.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist setuptools

cd /sources
rm -rf setuptools-80.9.0
echo "==> Setuptools klaar"
