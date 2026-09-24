# Draait BUITEN chroot, als root (zelfde reden als 03a/03b/03c/03d/
# hoofdstuk 8). Bronnen voor fase 4 (devstack): Node.js, Bun, gh,
# cloudflared, Supabase CLI en Tailscale komen als officiële prebuilt
# Linux-x86_64-binaries (normale, door de makers zelf aangeraden
# installatiewijze op een systeem zonder package manager — "Official
# Route First"). PostgreSQL en SQLite komen via BLFS 12.4 zoals de
# rest van dit project. Versies zijn een moment-opname (2026-09-23,
# opnieuw geverifieerd t.o.v. de eerdere BLUEPRINT.md-notitie van
# 2026-09-22 — ongewijzigd).
#
# NB: PWA-snelkoppelingen (Claude/ChatGPT/Mistral/Gemini) zijn BEWUST
# uitgesteld naar een eigen vervolgstap — vereisen een browser-engine
# (WebKitGTK, 21 SBU + een hele nieuwe afhankelijkheidsketen) die nog
# niet gebouwd is. Zie BLUEPRINT.md "Fase 4" voor de volledige
# onderbouwing en het aan Brionize voorgelegde besluit.
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  [node-v24.21.0-linux-x64.tar.xz]="https://nodejs.org/dist/v24.21.0/node-v24.21.0-linux-x64.tar.xz"
  [bun-linux-x64.zip]="https://github.com/oven-sh/bun/releases/download/bun-v1.4.2/bun-linux-x64.zip"
  [gh_2.101.0_linux_amd64.tar.gz]="https://github.com/cli/cli/releases/download/v2.101.0/gh_2.101.0_linux_amd64.tar.gz"
  [cloudflared-linux-amd64]="https://github.com/cloudflare/cloudflared/releases/download/2026.9.1/cloudflared-linux-amd64"
  [supabase_2.117.0_linux_amd64.tar.gz]="https://github.com/supabase/cli/releases/download/v2.117.0/supabase_2.117.0_linux_amd64.tar.gz"
  [tailscale_1.102.4_amd64.tgz]="https://pkgs.tailscale.com/stable/tailscale_1.102.4_amd64.tgz"
  [postgresql-17.6.tar.bz2]="https://ftp.postgresql.org/pub/source/v17.6/postgresql-17.6.tar.bz2"
  [sqlite-autoconf-3500400.tar.gz]="https://sqlite.org/2025/sqlite-autoconf-3500400.tar.gz"
)

declare -A MD5=(
  [node-v24.21.0-linux-x64.tar.xz]="74ae2c344f513204fc1191be93007c61"
  [bun-linux-x64.zip]="58faf31903d4d3c151cd04f9c06b0969"
  [gh_2.101.0_linux_amd64.tar.gz]="8094db32af03164f97c0256854405161"
  [cloudflared-linux-amd64]="7d803ac21c27da019038c191d1dc03a7"
  [supabase_2.117.0_linux_amd64.tar.gz]="cc6b06f8021fa21b842bfa4ae217dbcc"
  [tailscale_1.102.4_amd64.tgz]="7ea0d06df26f57354f1c87bef15a688b"
  [postgresql-17.6.tar.bz2]="e72b7e5dc22d44d56b113ed1f74e4084"
  [sqlite-autoconf-3500400.tar.gz]="d74bbdca4ab1b2bd46d3b3f8dbb0f3db"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-4-bronnen aanwezig en geverifieerd"
