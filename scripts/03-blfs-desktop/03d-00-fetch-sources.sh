# Draait BUITEN chroot, als root (zelfde reden als 03a/03b/03c/hoofdstuk 8).
# Bronnen voor fase 3d (Conky-HUD, window-tiling, 3 werkbladen/hotkeys —
# zie BLUEPRINT.md "Fase 3d"). Geen van deze vier pakketten staat in
# BLFS 12.4 (niche desktop-hulpprogramma's) — "Official Route First"
# betekent hier: elk pakket se EIGEN officiële upstream-bron (GitHub
# Releases/tags voor Conky/devilspie2, de officiële BLFS-pagina voor
# Lua, en voor wmctrl — waarvan de oorspronkelijke site dood is — de
# Wayback Machine, zelfde fallback-patroon als eerder bij ncurses).
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  # Lua — nodig voor devilspie2 (Lua-scriptregels) en Conky (Lua-config).
  [lua-5.4.8.tar.gz]="https://www.lua.org/ftp/lua-5.4.8.tar.gz"
  [lua-5.4.8-shared_library-1.patch]="https://www.linuxfromscratch.org/patches/blfs/12.4/lua-5.4.8-shared_library-1.patch"

  # wmctrl — oorspronkelijke site (tripie.sweb.cz) is dood; via Wayback
  # Machine (zelfde bewezen fallback als bij ncurses eerder dit project).
  [wmctrl-1.07.tar.gz]="http://web.archive.org/web/20221116085402/http://tripie.sweb.cz/utils/wmctrl/dist/wmctrl-1.07.tar.gz"

  # devilspie2 — officiële GitHub-tag van de hoofdontwikkelaar (gusnan).
  [devilspie2-0.36.tar.gz]="https://github.com/gusnan/devilspie2/archive/refs/tags/v0.36.tar.gz"

  # Conky — officiële GitHub-tag.
  [conky-1.24.2.tar.gz]="https://github.com/brndnmtthws/conky/archive/refs/tags/v1.24.2.tar.gz"
)

declare -A MD5=(
  [lua-5.4.8.tar.gz]="81cf5265b8634967d8a7480d238168ce"
  [lua-5.4.8-shared_library-1.patch]="dd9bafa25310f188f711b2670275e0cc"
  [wmctrl-1.07.tar.gz]="264fcc6a33b8309c6a32f41b29615b23"
  [devilspie2-0.36.tar.gz]="f25ee9078c033e47d93a76d5cb44968d"
  [conky-1.24.2.tar.gz]="2bac15f09ab48d8360a4f1e66ff3c2b8"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-3d-bronnen aanwezig en geverifieerd"
