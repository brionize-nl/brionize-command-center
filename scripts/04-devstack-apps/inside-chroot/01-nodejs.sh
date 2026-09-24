#!/bin/bash
# Node.js v24.21.0 (LTS "Krypton"). Draait binnen chroot, als root.
# Officiële prebuilt Linux-x86_64-tarball (nodejs.org/dist) — normale
# installatiewijze zonder package manager. Geen BLFS-pagina nodig,
# geen compilatie. Geïnstalleerd onder /opt (net als de andere fase-4-
# tools) met symlinks in /usr/local/bin — /usr/local is de FHS-plek
# voor niet-BLFS-software (al aangemaakt in hoofdstuk 7,
# 00-creating-dirs.sh), gescheiden van /usr (onze eigen from-source-
# BLFS-pakketten).
set -euo pipefail
cd /sources
mkdir -p /opt/nodejs
tar -xf node-v24.21.0-linux-x64.tar.xz -C /opt/nodejs --strip-components=1

for bin in node npm npx corepack; do
  ln -sfv "/opt/nodejs/bin/$bin" "/usr/local/bin/$bin"
done

echo "==> Node.js klaar: $(/opt/nodejs/bin/node --version)"
