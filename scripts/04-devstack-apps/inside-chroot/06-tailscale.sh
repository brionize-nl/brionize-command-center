#!/bin/bash
# Tailscale v1.102.4 (tailscale + tailscaled). Draait binnen chroot,
# als root. Officiële prebuilt Linux-x86_64-tarball
# (pkgs.tailscale.com) — statisch gelinkte Go-binaries.
#
# Alleen de twee programma's geïnstalleerd — de tarball bevat ook
# systemd-unit-files/udev-regels/manpages die bij een systemd-systeem
# horen (wij hebben geen systemd, alleen udev uit hoofdstuk 8). Het
# daadwerkelijk STARTEN/superviseren van tailscaled (en `tailscale up`
# met een auth-key) is een first-boot-/per-machine-taak (uniek
# apparaat-identiteit per installatie), niet iets om in het generieke
# image te bakken.
set -euo pipefail
cd /sources
mkdir -p tailscale-extract
tar -xf tailscale_1.102.4_amd64.tgz -C tailscale-extract --strip-components=1
install -v -m755 tailscale-extract/tailscale /usr/local/bin/tailscale
install -v -m755 tailscale-extract/tailscaled /usr/local/bin/tailscaled
rm -rf tailscale-extract

echo "==> Tailscale klaar: $(tailscale --version | head -1)"
