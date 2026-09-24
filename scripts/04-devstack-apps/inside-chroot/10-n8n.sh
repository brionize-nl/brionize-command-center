#!/bin/bash
# n8n 2.40.5 (workflow-automatisering). Draait binnen chroot, als root.
# Geen officiële losse Linux-binary — normale installatiewijze is
# `npm install -g n8n` (heeft dus Node.js, vorige stappen, nodig).
# Exacte versie gepind (niet @latest) voor reproduceerbaarheid — de
# eigen transitieve dependency-resolutie van npm kan desondanks licht
# variëren over tijd (inherent aan npm-installs, zelfde aanvaarde
# afweging als bij de pip3-installs in fase 3b/3c).
set -euo pipefail
npm install -g n8n@2.40.5

# npm plaatst globale binaries naast de node-executable zelf
# (/opt/nodejs/bin) — niet automatisch op PATH, dus expliciet
# symlinken naar /usr/local/bin (zelfde patroon als 01-nodejs.sh).
ln -sfv /opt/nodejs/bin/n8n /usr/local/bin/n8n

echo "==> n8n klaar: $(n8n --version)"
