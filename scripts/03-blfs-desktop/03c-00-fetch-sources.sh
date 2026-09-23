# Draait BUITEN chroot, als root (zelfde reden als 03a/03b/hoofdstuk 8).
# Bronnen voor fase 3c (BLFS 12.4): XFCE-core (17 pakketten) + de
# externe (niet-Xfce) Required/Recommended-dependencies die nog niet
# via 03a/03b aanwezig zijn. Volledige bouwvolgorde + onderbouwing: zie
# BLUEPRINT.md "Dependency-audit fase 3b/3c" + de aanvulling voor 03c.
# URL's/MD5's letterlijk van de officiële BLFS 12.4-boekpagina's.
#
# NB: GTK-3.24.50, Cairo-1.18.4, pcre2-10.45, shared-mime-info-2.4,
# GLib+GObject-Introspection, dbus, gsettings-desktop-schemas en
# at-spi2-core zijn AL aanwezig sinds 03b — hier niet opnieuw gefetcht.
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  # Externe dependencies, nog niet aanwezig
  [hwdata-0.398.tar.gz]="https://github.com/vcrhonek/hwdata/archive/v0.398/hwdata-0.398.tar.gz"
  [libdisplay-info-0.3.0.tar.xz]="https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/0.3.0/downloads/libdisplay-info-0.3.0.tar.xz"
  [hicolor-icon-theme-0.18.tar.xz]="https://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.18.tar.xz"
  [startup-notification-0.12.tar.gz]="https://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz"
  [libgudev-238.tar.xz]="https://download.gnome.org/sources/libgudev/238/libgudev-238.tar.xz"
  [desktop-file-utils-0.28.tar.xz]="https://www.freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.28.tar.xz"
  [lxde-icon-theme-0.5.1.tar.xz]="https://downloads.sourceforge.net/lxde/lxde-icon-theme-0.5.1.tar.xz"
  [libnotify-0.8.6.tar.xz]="https://download.gnome.org/sources/libnotify/0.8/libnotify-0.8.6.tar.xz"

  # libxslt — levert xsltproc; xfce4-dev-tools' eigen configure faalt
  # hard zonder dit ("package 'xsltproc' missing", geen optionele vlag
  # om te omzeilen zoals eerder bij GLib/gdk-pixbuf/GTK3's man-pages).
  [libxslt-1.1.43.tar.xz]="https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.43.tar.xz"

  # XFCE-core (17 pakketten, exacte bouwvolgorde in inside-chroot-03c/run-all.sh)
  [libxfce4util-4.20.1.tar.bz2]="https://archive.xfce.org/src/xfce/libxfce4util/4.20/libxfce4util-4.20.1.tar.bz2"
  [xfconf-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/xfconf/4.20/xfconf-4.20.0.tar.bz2"
  [libxfce4ui-4.20.2.tar.bz2]="https://archive.xfce.org/src/xfce/libxfce4ui/4.20/libxfce4ui-4.20.2.tar.bz2"
  [exo-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/exo/4.20/exo-4.20.0.tar.bz2"
  [garcon-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/garcon/4.20/garcon-4.20.0.tar.bz2"
  [libwnck-43.2.tar.xz]="https://download.gnome.org/sources/libwnck/43/libwnck-43.2.tar.xz"
  [xfce4-dev-tools-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/xfce4-dev-tools/4.20/xfce4-dev-tools-4.20.0.tar.bz2"
  [libxfce4windowing-4.20.4.tar.bz2]="https://archive.xfce.org/src/xfce/libxfce4windowing/4.20/libxfce4windowing-4.20.4.tar.bz2"
  [xfce4-panel-4.20.5.tar.bz2]="https://archive.xfce.org/src/xfce/xfce4-panel/4.20/xfce4-panel-4.20.5.tar.bz2"
  [thunar-4.20.4.tar.bz2]="https://archive.xfce.org/src/xfce/thunar/4.20/thunar-4.20.4.tar.bz2"
  [thunar-volman-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/thunar-volman/4.20/thunar-volman-4.20.0.tar.bz2"
  [tumbler-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/tumbler/4.20/tumbler-4.20.0.tar.bz2"
  [xfce4-appfinder-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/xfce4-appfinder/4.20/xfce4-appfinder-4.20.0.tar.bz2"
  [xfce4-settings-4.20.2.tar.bz2]="https://archive.xfce.org/src/xfce/xfce4-settings/4.20/xfce4-settings-4.20.2.tar.bz2"
  [xfdesktop-4.20.1.tar.bz2]="https://archive.xfce.org/src/xfce/xfdesktop/4.20/xfdesktop-4.20.1.tar.bz2"
  [xfwm4-4.20.0.tar.bz2]="https://archive.xfce.org/src/xfce/xfwm4/4.20/xfwm4-4.20.0.tar.bz2"
  [xfce4-session-4.20.3.tar.bz2]="https://archive.xfce.org/src/xfce/xfce4-session/4.20/xfce4-session-4.20.3.tar.bz2"
)

declare -A MD5=(
  [hwdata-0.398.tar.gz]="1ce78576cdde13f0e1953445a98bf173"
  [libdisplay-info-0.3.0.tar.xz]="f2a15697f6e8c66722b7760ceccbed60"
  [hicolor-icon-theme-0.18.tar.xz]="ef14f3af03bcde9ed134aad626bdbaad"
  [startup-notification-0.12.tar.gz]="2cd77326d4dcaed9a5a23a1232fb38e9"
  [libgudev-238.tar.xz]="46da30a1c69101c3a13fa660d9ab7b73"
  [desktop-file-utils-0.28.tar.xz]="dec5d7265c802db1fde3980356931b7b"
  [lxde-icon-theme-0.5.1.tar.xz]="7467133275edbbcc79349379235d4411"
  [libnotify-0.8.6.tar.xz]="09bce743badbe1c180ce14d92539afb9"
  [libxslt-1.1.43.tar.xz]="5dc0179c81be7a3082b43030ecfdebd4"

  [libxfce4util-4.20.1.tar.bz2]="8e30b7735333f74d80c379e15d9da145"
  [xfconf-4.20.0.tar.bz2]="ca596ff0a9be7fa655bb09cb05458644"
  [libxfce4ui-4.20.2.tar.bz2]="ce54074a9ed7964b4a3274e8ac74d949"
  [exo-4.20.0.tar.bz2]="f059ec3d8686d4b322c42d19ebec0366"
  [garcon-4.20.0.tar.bz2]="fe17e9cb15a62013e0086183a446e89e"
  [libwnck-43.2.tar.xz]="b8c29ef589d3427c8a699c1542a2d25e"
  [xfce4-dev-tools-4.20.0.tar.bz2]="bea58046e67b4274c022fcff893fa350"
  [libxfce4windowing-4.20.4.tar.bz2]="b27e6ebf153fbca5184147b6d3775762"
  [xfce4-panel-4.20.5.tar.bz2]="cf0d6ac7e084b1171e0b46756f2b3c5f"
  [thunar-4.20.4.tar.bz2]="3a9a8c5606348a51e0dee292fac0a280"
  [thunar-volman-4.20.0.tar.bz2]="34c8e0af77ea3894db7e3d164998f9bf"
  [tumbler-4.20.0.tar.bz2]="8746afe5822d3564a5cd43945d488db7"
  [xfce4-appfinder-4.20.0.tar.bz2]="e60f6c2521a985c6cfe09057d4fb2d69"
  [xfce4-settings-4.20.2.tar.bz2]="5f249a8398718995edb264b132059029"
  [xfdesktop-4.20.1.tar.bz2]="b845397fed5e555fa8dce4b189365dbc"
  [xfwm4-4.20.0.tar.bz2]="e74cfb30b6e9ebf9cbaac0827dd534e3"
  [xfce4-session-4.20.3.tar.bz2]="a97ee6039a463dd845b3869275f0c34e"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-3c-bronnen aanwezig en geverifieerd"
