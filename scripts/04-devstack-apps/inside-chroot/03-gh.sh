#!/bin/bash
# GitHub CLI (gh) v2.101.0. Draait binnen chroot, als root. Officiële
# prebuilt Linux-x86_64-tarball (GitHub Releases) — statisch gelinkte
# Go-binary, geen dynamische afhankelijkheden (geverifieerd met
# readelf vóór het schrijven van dit script).
set -euo pipefail
cd /sources
tar -xf gh_2.101.0_linux_amd64.tar.gz
install -v -m755 gh_2.101.0_linux_amd64/bin/gh /usr/local/bin/gh
install -v -dm755 /usr/local/share/man/man1
install -v -m644 gh_2.101.0_linux_amd64/share/man/man1/*.1 /usr/local/share/man/man1/ 2>/dev/null || true
rm -rf gh_2.101.0_linux_amd64

echo "==> gh klaar: $(gh --version | head -1)"
