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
    -W no-dev -G Ninja ..
ninja -j2
ninja install

cd /sources
rm -rf webkitgtk-2.48.5
echo "==> WebKitGTK klaar"
