#!/bin/bash
# BLFS 12.4 — WebKitGTK-2.48.5. Draait binnen chroot, als root. Alle
# Required-dependencies aanwezig na de vorige 18 stappen + eerdere
# fasen (Cairo/CMake/GTK-3/libgudev/Mesa/SQLite uit 03a-b/04).
#
# BELANGRIJKE WAARSCHUWING UIT HET BOEK ZELF, DIRECT OPGEVOLGD (niet
# gegokt): "With the default 'release' build configuration, some
# source files of this package require more than 4 GiB of RAM to be
# built. [...] pass -j<N> to ninja [...] to limit the number of
# parallel jobs and avoid the job from being killed by the kernel OOM
# killer." GitHub Actions-standaardrunners hebben 16GB RAM — bij het
# standaard `ninja` (auto-parallel, meestal gelijk aan het aantal
# cores +1/+2) zouden 4+ gelijktijdige jobs × >4GB al het beschikbare
# geheugen kunnen opeisen, zonder marge voor de OS/container-overhead.
# Daarom hier EXPLICIET '-j2' (i.p.v. het algemene -j4-patroon van
# andere fasen) — 2 × ~4GB = ~8GB, ruim binnen 16GB met marge.
#
# '-D USE_GTK4=OFF' — wij gebruiken de GTK-3-variant (matcht onze
# hele XFCE/GTK3-desktop, niet de apart te bouwen GTK-4-stack).
# '-D ENABLE_BUBBLEWRAP_SANDBOX=OFF' — AFWIJKING t.o.v. het boek (dat
# 'ON' zet): bubblewrap is alleen "Recommended" voor WebKitGTK en is
# niet gebouwd; uit staat voorkomt een mogelijke harde build-time-
# afhankelijkheidscheck. Betekent wel: geen sandbox-isolatie voor
# webcontent-processen — een bekende, bewuste beperking (geen
# stilzwijgende scope-verkleining), te heroverwegen als bubblewrap
# ooit alsnog gebouwd wordt. Overige vlaggen letterlijk het boek's
# GTK-3-bouwcommando.
#
# Achtste CI-run (2026-09-26) faalde vervolgens op "Enchant is needed
# for ENABLE_SPELLCHECK" — WebKitGTK's eigen OptionsGTK.cmake zet
# ENABLE_SPELLCHECK/USE_AVIF/USE_JPEGXL alle drie op ON specifiek voor
# de GTK-port (WEBKIT_OPTION_DEFAULT_PORT_VALUE), los van hun globale
# standaardwaarde. Volledig lokaal nagelopen (alle
# WEBKIT_OPTION_DEFAULT_PORT_VALUE-regels in OptionsGTK.cmake) om dit
# in één keer af te ronden i.p.v. drie losse CI-rondes:
# - ENABLE_SPELLCHECK → Enchant nodig (spellingscontrole; niet nodig
#   voor onze kiosk-browser/tegel-manager-use-case) → OFF.
# - USE_AVIF/USE_JPEGXL → libavif/libjxl nodig (extra beeldformaten;
#   geen van onze AI-webapps hangt hiervan af, en beide hebben zelf
#   weer zware afhankelijkheidsketens (libaom/dav1d resp. highway/
#   brotli)) → beide OFF, zelfde minimale-footprint-redenering als de
#   al bestaande ENABLE_GAMEPAD/ENABLE_SPEECH_SYNTHESIS-keuzes.
# - USE_LCMS staat ook op ON via dit mechanisme, maar dat klopt met
#   onze eigen keuze: lcms2 is al gebouwd (stap 09) — geen wijziging.
set -euo pipefail
cd /sources
tar -xf webkitgtk-2.48.5.tar.xz
cd webkitgtk-2.48.5

mkdir -vp build
cd build

cmake -D CMAKE_BUILD_TYPE=Release     \
    -D CMAKE_INSTALL_PREFIX=/usr    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON  \
    -D PORT=GTK                     \
    -D LIB_INSTALL_DIR=/usr/lib     \
    -D USE_LIBBACKTRACE=OFF         \
    -D USE_LIBHYPHEN=OFF            \
    -D ENABLE_GAMEPAD=OFF           \
    -D ENABLE_MINIBROWSER=ON        \
    -D ENABLE_DOCUMENTATION=OFF     \
    -D ENABLE_WEBDRIVER=OFF         \
    -D USE_WOFF2=OFF                \
    -D USE_GTK4=OFF                 \
    -D ENABLE_JOURNALD_LOG=OFF      \
    -D ENABLE_BUBBLEWRAP_SANDBOX=OFF \
    -D USE_SYSPROF_CAPTURE=NO       \
    -D ENABLE_SPEECH_SYNTHESIS=OFF  \
    -D ENABLE_SPELLCHECK=OFF        \
    -D USE_AVIF=OFF                 \
    -D USE_JPEGXL=OFF               \
    -W no-dev -G Ninja ..
ninja -j2
ninja install

cd /sources
rm -rf webkitgtk-2.48.5
echo "==> WebKitGTK klaar"
