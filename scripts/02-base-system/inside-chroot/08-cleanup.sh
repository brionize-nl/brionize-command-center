#!/bin/bash
# LFS 12.4 hoofdstuk 7.13 — Cleanup. Draait binnen chroot, als root.
# Verwijdert het tijdelijke /tools-toolchain en documentatie/.la-bestanden
# nu het systeem zichzelf kan hosten.
set -euo pipefail

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name '*.la' -delete
rm -rf /tools

echo "==> Cleanup klaar — hoofdstuk 7 (chroot temporary tools) compleet"
