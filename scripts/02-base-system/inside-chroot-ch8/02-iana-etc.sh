#!/bin/bash
# LFS 12.4 hoofdstuk 8.4 — Iana-Etc-20250807. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf iana-etc-20250807.tar.gz
cd iana-etc-20250807

cp services protocols /etc

cd /sources
rm -rf iana-etc-20250807
echo "==> Iana-Etc klaar"
