#!/bin/bash
# cloudflared 2026.9.1. Draait binnen chroot, als root. Officiële
# prebuilt Linux-x86_64-binary (GitHub Releases) — geen tarball, één
# los ELF-bestand. Statisch gelinkte Go-binary, geen dynamische
# afhankelijkheden.
set -euo pipefail
cd /sources
install -v -m755 cloudflared-linux-amd64 /usr/local/bin/cloudflared

echo "==> cloudflared klaar: $(cloudflared --version)"
