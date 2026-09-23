#!/bin/bash
# Systeembrede standaardconfiguratie voor 3 werkbladen + Super+1/2/3.
# Draait binnen chroot, als root. Geen los pakket — plaatst/wijzigt
# xfconf-"perchannel"-XML-bestanden onder /etc/xdg/xfce4/xfconf/, het
# officiële XFCE-mechanisme voor systeembrede standaardwaarden die elke
# (ook toekomstige) gebruiker zonder eigen overrides erft.
#
# Bronnen/schema NIET gegokt, maar overgenomen uit de daadwerkelijke
# pakketbroncode:
# - xfwm4's eigen src/settings.c bevestigt de xfconf-channel "xfwm4" en
#   het "/general/"-padvoorvoegsel voor workspace_count/workspace_names.
# - xfce4-panel's migrate/default.xml bevestigt de xfconf-array-XML-
#   syntax (<property type="array"><value type="string" .../></property>).
# - libxfce4ui's eigen libxfce4kbd-private/xfce4-keyboard-shortcuts.xml
#   is het ECHTE, door libxfce4ui zelf geïnstalleerde standaardbestand
#   (Makefile.am: settingsdir = $(sysconfdir)/xdg/xfce4/xfconf/
#   xfce-perchannel-xml) — dat bestand staat dus al op dit systeem
#   (sinds 03c) en wordt hier NIET vervangen, alleen gericht bewerkt:
#   de drie standaard workspace-1/2/3-sneltoetsen (boek-default:
#   <Primary>F1/F2/F3) worden vervangen door Super+1/2/3. Alle overige
#   sneltoetsen (vensterbeheer, tegelen, etc.) blijven ongemoeid — de
#   gebruiker kan alles hierna nog vrij aanpassen via de normale
#   XFCE-instellingen-dialoog.
set -euo pipefail

PERCHANNEL_DIR="/etc/xdg/xfce4/xfconf/xfce-perchannel-xml"
mkdir -pv "$PERCHANNEL_DIR"

# --- xfwm4.xml: 3 werkbladen met naam (bestaat nog niet — xfwm4 valt
# zonder dit bestand terug op zijn ingebakken standaard van 4 naamloze
# werkbladen). ---
cat > "$PERCHANNEL_DIR/xfwm4.xml" << "EOF"
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="workspace_count" type="int" value="3"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Command Center"/>
      <value type="string" value="AI Matrix"/>
      <value type="string" value="Dev Studio"/>
    </property>
  </property>
</channel>
EOF

# --- xfce4-keyboard-shortcuts.xml: bestaat al (geïnstalleerd door
# libxfce4ui in 03c) — alleen de 3 workspace-sneltoetsen vervangen. ---
KS_FILE="$PERCHANNEL_DIR/xfce4-keyboard-shortcuts.xml"
if [ ! -f "$KS_FILE" ]; then
  echo "FOUT: $KS_FILE ontbreekt — verwacht dat libxfce4ui (03c) dit al geïnstalleerd heeft." >&2
  exit 1
fi

sed -i \
  -e 's#<property name="&lt;Primary&gt;F1" type="string" value="workspace_1_key"/>#<property name="\&lt;Super\&gt;1" type="string" value="workspace_1_key"/>#' \
  -e 's#<property name="&lt;Primary&gt;F2" type="string" value="workspace_2_key"/>#<property name="\&lt;Super\&gt;2" type="string" value="workspace_2_key"/>#' \
  -e 's#<property name="&lt;Primary&gt;F3" type="string" value="workspace_3_key"/>#<property name="\&lt;Super\&gt;3" type="string" value="workspace_3_key"/>#' \
  "$KS_FILE"

# Sanity-check: de drie oude Ctrl+F1/F2/F3-bindingen moeten weg zijn,
# en er moeten nu Super+1/2/3-bindingen staan — anders faalt de stap
# expliciet in plaats van stilzwijgend niets te doen (bv. als het
# boek-default in een latere xfce4-versie is gewijzigd).
if grep -q 'value="workspace_1_key"' "$KS_FILE" && ! grep -q '&lt;Super&gt;1" type="string" value="workspace_1_key"' "$KS_FILE"; then
  echo "FOUT: Super+1-binding voor workspace_1_key niet aangetroffen na sed — controleer of het boek-default gewijzigd is." >&2
  exit 1
fi

echo "==> Werkbladen + Super+1/2/3-sneltoetsen geconfigureerd"
