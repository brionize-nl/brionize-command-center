#!/bin/bash
# Installeert de window-tiling-regels (command-center-tiling.lua) voor
# devilspie2. Draait binnen chroot, als root. Geen los pakket.
#
# Bestemming: /etc/skel/.config/devilspie2/ (NIET /etc/xdg/...) —
# devilspie2's eigen README (letterlijk gelezen) bevestigt dat het
# ALLEEN uit g_get_user_config_dir()/devilspie2/ leest, geen
# systeembrede /etc/xdg-fallback kent zoals xfconf dat wel heeft. Een
# bestand onder /etc/skel wordt door useradd (-m) naar elke nieuwe
# gebruiker gekopieerd — het equivalent van een systeembrede default
# voor een pakket dat zelf geen systeembrede configuratie ondersteunt.
#
# Evidence-verificatie: Lua-SYNTAX gecontroleerd met luac -p (uit
# Lua-5.4.8, 01-lua.sh) — dit bewijst dat het bestand geldige Lua is,
# NIET dat de devilspie2-functieaanroepen/titelpatronen runtime correct
# zijn (kan niet zonder live X-sessie + de daadwerkelijke apps, die pas
# in fase 4 bestaan). Zie de kanttekening in het .lua-bestand zelf.
set -euo pipefail

SKEL_DIR="/etc/skel/.config/devilspie2"
mkdir -pv "$SKEL_DIR"
cp "$(dirname "$0")/command-center-tiling.lua" "$SKEL_DIR/command-center-tiling.lua"

echo "==> Lua-syntaxcontrole (luac -p)"
luac -p "$SKEL_DIR/command-center-tiling.lua"

echo "==> devilspie2-tegelregels geïnstalleerd en syntactisch geldig"
