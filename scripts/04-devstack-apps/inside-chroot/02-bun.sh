#!/bin/bash
# Bun v1.4.2. Draait binnen chroot, als root. Officiële prebuilt
# Linux-x86_64-zip (GitHub Releases). Geen `unzip` gebouwd/nodig —
# Python3 (al aanwezig sinds hoofdstuk 8) pakt .zip-bestanden ook uit
# via de ingebouwde zipfile-module.
set -euo pipefail
cd /sources
mkdir -p /opt/bun
python3 -m zipfile -e bun-linux-x64.zip /opt/bun/
mv /opt/bun/bun-linux-x64/bun /opt/bun/bun
rmdir /opt/bun/bun-linux-x64
chmod +x /opt/bun/bun

ln -sfv /opt/bun/bun /usr/local/bin/bun

echo "==> Bun klaar: $(/opt/bun/bun --version)"
