#!/bin/bash
# PM2 v7.0.4 (proces-manager/watchdog). Draait binnen chroot, als
# root. `npm install -g pm2` (heeft Node.js nodig).
#
# Vervangt hier BEWUST de "systemd watchdogs" uit BLUEPRINT's
# oorspronkelijke fase-4-omschrijving: dit systeem heeft GEEN systemd
# (alleen udev uit hoofdstuk 8, zie BLUEPRINT.md "Architectuur/
# Aanpak"). PM2 is zelf al een procesbeheerder met automatisch-
# herstarten-bij-crash ("zelfherstellend") en staat al los in de
# devstack-lijst — dekt dus dezelfde functie zonder systemd nodig te
# hebben. Het DAADWERKELIJK instellen van PM2-procesdefinities voor
# n8n/cloudflared-tunnel/etc. (pm2 start ... && pm2 save) is een
# first-boot-/per-machine-taak, niet iets om statisch in het generieke
# image te bakken (zelfde architectuur-scheiding als bij PostgreSQL's
# initdb hiervoor).
set -euo pipefail
npm install -g pm2@7.0.4

ln -sfv /opt/nodejs/bin/pm2 /usr/local/bin/pm2

echo "==> PM2 klaar: $(pm2 --version)"
