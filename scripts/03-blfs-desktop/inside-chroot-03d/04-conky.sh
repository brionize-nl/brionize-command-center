#!/bin/bash
# Conky-1.24.2. Draait binnen chroot, als root. Niet in BLFS —
# officiële GitHub-tag. CMake-gebaseerd met een zeer uitgebreide set
# feature-vlaggen (cmake/ConkyBuildOptions.cmake letterlijk nagekeken,
# niet gegokt) — bewust MINIMAAL gehouden, passend bij het BLUEPRINT.md-
# doel ("live systeem-HUD: CPU/RAM/opslag, Tailscale-status, logs"):
# - BUILD_X11=ON, BUILD_XFT=ON: nodig voor een leesbare, op X11
#   getekende HUD (freetype/fontconfig/harfbuzz al aanwezig uit 03a/03b).
# - BUILD_WAYLAND=OFF: bewust X11-only-doel (geen wayland gebouwd).
# - BUILD_IMLIB2=OFF: staat in het boek default AAN (vereist BUILD_X11),
#   maar Imlib2 is niet gebouwd — alleen nodig voor afbeeldingen in de
#   HUD, niet voor tekst/grafieken.
# - BUILD_JOURNAL=OFF, BUILD_PULSEAUDIO=OFF, BUILD_MYSQL=OFF,
#   BUILD_WLAN=OFF, BUILD_NVIDIA_NVML=OFF: staan al standaard uit in het
#   boek/CMake-defaults (geen systemd/pulseaudio/mysql/nvidia gebouwd),
#   hier expliciet herhaald voor duidelijkheid/toekomstvastheid.
# 'find_package(Lua "5.3" REQUIRED)' is ONVOORWAARDELIJK (niet
# uitschakelbaar) — Lua-5.4.8 (vorige stap) voldoet aan ">=5.3".
set -euo pipefail
cd /sources
tar -xf conky-1.24.2.tar.gz
cd conky-1.24.2

# Eigen HUD-standaardconfiguratie (CPU/RAM/opslag/Tailscale-status/
# logs, zie BLUEPRINT.md) vervangt Conky's eigen voorbeeldconfig.
# BUILD_BUILTIN_CONFIG (boek-default AAN, hier niet gewijzigd) bakt dit
# bestand ten tijde van bouwen in de executable in via text2c — wordt
# zo de standaard-HUD voor elke gebruiker, zonder losse configuratiestap.
cp "$(dirname "$0")/conky-command-center.conf" data/conky.conf

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D BUILD_WAYLAND=OFF         \
    -D BUILD_X11=ON              \
    -D BUILD_XFT=ON              \
    -D BUILD_IMLIB2=OFF          \
    -D BUILD_JOURNAL=OFF         \
    -D BUILD_PULSEAUDIO=OFF      \
    -D BUILD_MYSQL=OFF           \
    -D BUILD_WLAN=OFF            \
    -D BUILD_NVIDIA_NVML=OFF     \
    -D BUILD_DOCS=OFF            \
    -D BUILD_EXTRAS=OFF          \
    -D BUILD_TESTING=OFF         \
    -G Ninja ..
ninja
ninja install

cd /sources
rm -rf conky-1.24.2
echo "==> Conky klaar"
