#!/bin/bash
# LFS 12.4 hoofdstuk 8.74 — MarkupSafe-3.0.2. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf markupsafe-3.0.2.tar.gz
cd markupsafe-3.0.2

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist Markupsafe

cd /sources
rm -rf markupsafe-3.0.2
echo "==> MarkupSafe klaar"
