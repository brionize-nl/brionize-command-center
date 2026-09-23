#!/bin/bash
# Command-Center-Matrix: Matrix/cyberpunk GTK3-thema (diepzwart, neon-
# groen/cyaan). Draait binnen chroot, als root. Geen los pakket —
# gebouwd bovenop GTK3's ingebakken Adwaita-dark, zie de uitgebreide
# onderbouwing in command-center-matrix-gtk.css en BLUEPRINT.md.
#
# Bewuste scope-grens: dit dekt GTK3-toepassingen (verreweg het meeste
# zichtbare oppervlak — panel, Thunar, dialogen, menu's, tekst). xfwm4
# se eigen randdecoratie/titelbalk-thema (een apart, bitmap-gebaseerd
# systeem, los van GTK-CSS) blijft op het standaard "Default"-thema —
# eigen randgrafiek tekenen valt buiten wat hier met tekst/CSS
# redelijk te doen is. Vastgelegd als bekende grens, niet stilzwijgend
# weggelaten.
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
THEME_DIR="/usr/share/themes/Command-Center-Matrix"

mkdir -pv "$THEME_DIR/gtk-3.0"
cp "$SCRIPT_DIR/command-center-matrix-index.theme" "$THEME_DIR/index.theme"
cp "$SCRIPT_DIR/command-center-matrix-gtk.css" "$THEME_DIR/gtk-3.0/gtk.css"

# xsettings.xml bestaat al (geïnstalleerd door xfce4-settings in 03c) —
# alleen ThemeName gericht wijzigen, net als eerder bij
# xfce4-keyboard-shortcuts.xml (05-workspaces-hotkeys.sh).
XS_FILE="/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
if [ ! -f "$XS_FILE" ]; then
  echo "FOUT: $XS_FILE ontbreekt — verwacht dat xfce4-settings (03c) dit al geïnstalleerd heeft." >&2
  exit 1
fi

sed -i \
  -e 's#<property name="ThemeName" type="string" value="Adwaita"/>#<property name="ThemeName" type="string" value="Command-Center-Matrix"/>#' \
  "$XS_FILE"

if ! grep -q 'name="ThemeName" type="string" value="Command-Center-Matrix"' "$XS_FILE"; then
  echo "FOUT: ThemeName-vervanging niet aangetroffen na sed — controleer of het boek-default gewijzigd is." >&2
  exit 1
fi

echo "==> Command-Center-Matrix-thema geïnstalleerd en actief gezet"
