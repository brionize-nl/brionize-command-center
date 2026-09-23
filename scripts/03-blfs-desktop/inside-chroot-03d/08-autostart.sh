#!/bin/bash
# Autostart-entries voor Conky-HUD en devilspie2 (window-tiling) —
# zonder dit start geen van beide vanzelf bij het inloggen. Draait
# binnen chroot, als root. Formaat + installatiepad letterlijk
# overgenomen van xfce4-settings' eigen xfsettingsd.desktop.in
# (Makefile.am: autostartdir = $(sysconfdir)/xdg/autostart) — hetzelfde
# freedesktop-autostart-mechanisme dat xfce4-session voor elke
# gebruiker doorloopt.
set -euo pipefail

mkdir -pv /etc/xdg/autostart

cat > /etc/xdg/autostart/command-center-conky.desktop << "EOF"
[Desktop Entry]
Version=1.0
Name=Command Center HUD (Conky)
Comment=Live systeem-HUD: CPU/RAM/opslag, Tailscale-status, logs
Exec=conky
Icon=utilities-system-monitor
Terminal=false
Type=Application
StartupNotify=false
OnlyShowIn=XFCE;
Categories=System;Monitor;
EOF

cat > /etc/xdg/autostart/command-center-devilspie2.desktop << "EOF"
[Desktop Entry]
Version=1.0
Name=Command Center Window Tiling (devilspie2)
Comment=Past de werkblad-/tegelregels toe (zie ~/.config/devilspie2/)
Exec=devilspie2
Icon=preferences-system-windows
Terminal=false
Type=Application
StartupNotify=false
OnlyShowIn=XFCE;
Categories=System;
EOF

echo "==> Autostart-entries voor Conky en devilspie2 geïnstalleerd"
