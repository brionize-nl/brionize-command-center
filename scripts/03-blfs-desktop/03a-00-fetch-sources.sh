#!/bin/bash
# Draait BUITEN chroot, als root (zelfde reden als hoofdstuk 8: de
# 'lfs'-gebruiker heeft na hoofdstuk 7's chown geen rechten meer).
# Bronnen voor fase 3a (BLFS 12.4): proto/util-laag, de x7lib.html- en
# x7font.html-batches (32 + 9 pakketten, generieke lus), en xorg-server +
# zijn vereiste losse dependencies (libxcvt, pixman, xkeyboard-config).
# URL's/MD5's letterlijk van de officiële BLFS 12.4-boekpagina's.
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  # Proto/util-laag
  [util-macros-1.20.2.tar.xz]="https://www.x.org/pub/individual/util/util-macros-1.20.2.tar.xz"
  [xorgproto-2024.1.tar.xz]="https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2024.1.tar.xz"
  [libXau-1.0.12.tar.xz]="https://www.x.org/pub/individual/lib/libXau-1.0.12.tar.xz"
  [libXdmcp-1.1.5.tar.xz]="https://www.x.org/pub/individual/lib/libXdmcp-1.1.5.tar.xz"
  [xcb-proto-1.17.0.tar.xz]="https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.17.0.tar.xz"
  [libxcb-1.17.0.tar.xz]="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz"
  [xcb-util-0.4.1.tar.xz]="https://xcb.freedesktop.org/dist/xcb-util-0.4.1.tar.xz"

  # Freetype — vereist door libXft (in de x7lib-lus hieronder); hoorde
  # oorspronkelijk bij een latere GTK-stack-sub-fase, maar is al hier nodig.
  [freetype-2.13.3.tar.xz]="https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz"

  # Fontconfig — ook vereist door libXft (naast Freetype hierboven), zelfde
  # reden: pas ontdekt via een echte configure-fout in de x7lib-lus.
  [fontconfig-2.17.1.tar.xz]="https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/2.17.1/fontconfig-2.17.1.tar.xz"

  # x7lib.html — 32 Xorg-bibliotheken (generieke lus, zie 08-x7lib-loop.sh)
  [xtrans-1.6.0.tar.xz]="https://www.x.org/pub/individual/lib/xtrans-1.6.0.tar.xz"
  [libX11-1.8.12.tar.xz]="https://www.x.org/pub/individual/lib/libX11-1.8.12.tar.xz"
  [libXext-1.3.6.tar.xz]="https://www.x.org/pub/individual/lib/libXext-1.3.6.tar.xz"
  [libFS-1.0.10.tar.xz]="https://www.x.org/pub/individual/lib/libFS-1.0.10.tar.xz"
  [libICE-1.1.2.tar.xz]="https://www.x.org/pub/individual/lib/libICE-1.1.2.tar.xz"
  [libSM-1.2.6.tar.xz]="https://www.x.org/pub/individual/lib/libSM-1.2.6.tar.xz"
  [libXScrnSaver-1.2.4.tar.xz]="https://www.x.org/pub/individual/lib/libXScrnSaver-1.2.4.tar.xz"
  [libXt-1.3.1.tar.xz]="https://www.x.org/pub/individual/lib/libXt-1.3.1.tar.xz"
  [libXmu-1.2.1.tar.xz]="https://www.x.org/pub/individual/lib/libXmu-1.2.1.tar.xz"
  [libXpm-3.5.17.tar.xz]="https://www.x.org/pub/individual/lib/libXpm-3.5.17.tar.xz"
  [libXaw-1.0.16.tar.xz]="https://www.x.org/pub/individual/lib/libXaw-1.0.16.tar.xz"
  [libXfixes-6.0.1.tar.xz]="https://www.x.org/pub/individual/lib/libXfixes-6.0.1.tar.xz"
  [libXcomposite-0.4.6.tar.xz]="https://www.x.org/pub/individual/lib/libXcomposite-0.4.6.tar.xz"
  [libXrender-0.9.12.tar.xz]="https://www.x.org/pub/individual/lib/libXrender-0.9.12.tar.xz"
  [libXcursor-1.2.3.tar.xz]="https://www.x.org/pub/individual/lib/libXcursor-1.2.3.tar.xz"
  [libXdamage-1.1.6.tar.xz]="https://www.x.org/pub/individual/lib/libXdamage-1.1.6.tar.xz"
  [libfontenc-1.1.8.tar.xz]="https://www.x.org/pub/individual/lib/libfontenc-1.1.8.tar.xz"
  [libXfont2-2.0.7.tar.xz]="https://www.x.org/pub/individual/lib/libXfont2-2.0.7.tar.xz"
  [libXft-2.3.9.tar.xz]="https://www.x.org/pub/individual/lib/libXft-2.3.9.tar.xz"
  [libXi-1.8.2.tar.xz]="https://www.x.org/pub/individual/lib/libXi-1.8.2.tar.xz"
  [libXinerama-1.1.5.tar.xz]="https://www.x.org/pub/individual/lib/libXinerama-1.1.5.tar.xz"
  [libXrandr-1.5.4.tar.xz]="https://www.x.org/pub/individual/lib/libXrandr-1.5.4.tar.xz"
  [libXres-1.2.2.tar.xz]="https://www.x.org/pub/individual/lib/libXres-1.2.2.tar.xz"
  [libXtst-1.2.5.tar.xz]="https://www.x.org/pub/individual/lib/libXtst-1.2.5.tar.xz"
  [libXv-1.0.13.tar.xz]="https://www.x.org/pub/individual/lib/libXv-1.0.13.tar.xz"
  [libXvMC-1.0.14.tar.xz]="https://www.x.org/pub/individual/lib/libXvMC-1.0.14.tar.xz"
  [libXxf86dga-1.1.6.tar.xz]="https://www.x.org/pub/individual/lib/libXxf86dga-1.1.6.tar.xz"
  [libXxf86vm-1.1.6.tar.xz]="https://www.x.org/pub/individual/lib/libXxf86vm-1.1.6.tar.xz"
  [libpciaccess-0.18.1.tar.xz]="https://www.x.org/pub/individual/lib/libpciaccess-0.18.1.tar.xz"
  [libxkbfile-1.1.3.tar.xz]="https://www.x.org/pub/individual/lib/libxkbfile-1.1.3.tar.xz"
  [libxshmfence-1.3.3.tar.xz]="https://www.x.org/pub/individual/lib/libxshmfence-1.3.3.tar.xz"
  [libXpresent-1.0.1.tar.xz]="https://www.x.org/pub/individual/lib/libXpresent-1.0.1.tar.xz"

  # mkfontscale — vereist door encodings (onderdeel van de x7font-lus
  # hieronder): "mkfontscale is required to build encodings." Losstaand uit
  # de x7app.html-batch getrokken (33 pakketten, met als aggregate
  # "Required" o.a. Mesa) — we bouwen NIET de hele batch, alleen dit ene
  # pakket, om de bewuste Mesa/glamor-vrije keuze bij xorg-server niet
  # alsnog via de achterdeur te doorbreken.
  [mkfontscale-1.2.3.tar.xz]="https://www.x.org/pub/individual/app/mkfontscale-1.2.3.tar.xz"

  # x7font.html — 9 fontpakketten (generieke lus, zie 09-x7font-loop.sh)
  [font-util-1.4.1.tar.xz]="https://www.x.org/pub/individual/font/font-util-1.4.1.tar.xz"
  [encodings-1.1.0.tar.xz]="https://www.x.org/pub/individual/font/encodings-1.1.0.tar.xz"
  [font-alias-1.0.5.tar.xz]="https://www.x.org/pub/individual/font/font-alias-1.0.5.tar.xz"
  [font-adobe-utopia-type1-1.0.5.tar.xz]="https://www.x.org/pub/individual/font/font-adobe-utopia-type1-1.0.5.tar.xz"
  [font-bh-ttf-1.0.4.tar.xz]="https://www.x.org/pub/individual/font/font-bh-ttf-1.0.4.tar.xz"
  [font-bh-type1-1.0.4.tar.xz]="https://www.x.org/pub/individual/font/font-bh-type1-1.0.4.tar.xz"
  [font-ibm-type1-1.0.4.tar.xz]="https://www.x.org/pub/individual/font/font-ibm-type1-1.0.4.tar.xz"
  [font-misc-ethiopic-1.0.5.tar.xz]="https://www.x.org/pub/individual/font/font-misc-ethiopic-1.0.5.tar.xz"
  [font-xfree86-type1-1.0.5.tar.xz]="https://www.x.org/pub/individual/font/font-xfree86-type1-1.0.5.tar.xz"

  # xorg-server + losse vereiste dependencies
  [libxcvt-0.1.3.tar.xz]="https://www.x.org/pub/individual/lib/libxcvt-0.1.3.tar.xz"
  [pixman-0.46.4.tar.gz]="https://www.cairographics.org/releases/pixman-0.46.4.tar.gz"
  [xkeyboard-config-2.45.tar.xz]="https://www.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.45.tar.xz"
  [xorg-server-21.1.18.tar.xz]="https://www.x.org/pub/individual/xserver/xorg-server-21.1.18.tar.xz"
)

declare -A MD5=(
  [util-macros-1.20.2.tar.xz]="5f683a1966834b0a6ae07b3680bcb863"
  [xorgproto-2024.1.tar.xz]="12374d29fb5ae642cfa872035e401640"
  [libXau-1.0.12.tar.xz]="4c9f81acf00b62e5de56a912691bd737"
  [libXdmcp-1.1.5.tar.xz]="ce0af51de211e4c99a111e64ae1df290"
  [xcb-proto-1.17.0.tar.xz]="c415553d2ee1a8cea43c3234a079b53f"
  [libxcb-1.17.0.tar.xz]="96565523e9f9b701fcb35d31f1d4086e"
  [xcb-util-0.4.1.tar.xz]="34d749eab0fd0ffd519ac64798d79847"
  [freetype-2.13.3.tar.xz]="f3b4432c4212064c00500e1ad63fbc64"
  [fontconfig-2.17.1.tar.xz]="f68f95052c7297b98eccb7709d817f6a"

  [xtrans-1.6.0.tar.xz]="6ad67d4858814ac24e618b8072900664"
  [libX11-1.8.12.tar.xz]="146d770e564812e00f97e0cbdce632b7"
  [libXext-1.3.6.tar.xz]="e59476db179e48c1fb4487c12d0105d1"
  [libFS-1.0.10.tar.xz]="c5cc0942ed39c49b8fcd47a427bd4305"
  [libICE-1.1.2.tar.xz]="d1ffde0a07709654b20bada3f9abdd16"
  [libSM-1.2.6.tar.xz]="3aeeea05091db1c69e6f768e0950a431"
  [libXScrnSaver-1.2.4.tar.xz]="e613751d38e13aa0d0fd8e0149cec057"
  [libXt-1.3.1.tar.xz]="9acd189c68750b5028cf120e53c68009"
  [libXmu-1.2.1.tar.xz]="85edefb7deaad4590a03fccba517669f"
  [libXpm-3.5.17.tar.xz]="05b5667aadd476d77e9b5ba1a1de213e"
  [libXaw-1.0.16.tar.xz]="2a9793533224f92ddad256492265dd82"
  [libXfixes-6.0.1.tar.xz]="65b9ba1e9ff3d16c4fa72915d4bb585a"
  [libXcomposite-0.4.6.tar.xz]="af0a5f0abb5b55f8411cd738cf0e5259"
  [libXrender-0.9.12.tar.xz]="4c54dce455d96e3bdee90823b0869f89"
  [libXcursor-1.2.3.tar.xz]="5ce55e952ec2d84d9817169d5fdb7865"
  [libXdamage-1.1.6.tar.xz]="ca55d29fa0a8b5c4a89f609a7952ebf8"
  [libfontenc-1.1.8.tar.xz]="8816cc44d06ebe42e85950b368185826"
  [libXfont2-2.0.7.tar.xz]="66e03e3405d923dfaf319d6f2b47e3da"
  [libXft-2.3.9.tar.xz]="d378be0fcbd1f689f9a132e0d642bc4b"
  [libXi-1.8.2.tar.xz]="95a960c1692a83cc551979f7ffe28cf4"
  [libXinerama-1.1.5.tar.xz]="228c877558c265d2f63c56a03f7d3f21"
  [libXrandr-1.5.4.tar.xz]="24e0b72abe16efce9bf10579beaffc27"
  [libXres-1.2.2.tar.xz]="66c9e9e01b0b53052bb1d02ebf8d7040"
  [libXtst-1.2.5.tar.xz]="b62dc44d8e63a67bb10230d54c44dcb7"
  [libXv-1.0.13.tar.xz]="8a26503185afcb1bbd2c65e43f775a67"
  [libXvMC-1.0.14.tar.xz]="a90a5f01102dc445c7decbbd9ef77608"
  [libXxf86dga-1.1.6.tar.xz]="74d1acf93b83abeb0954824da0ec400b"
  [libXxf86vm-1.1.6.tar.xz]="d3db4b6dc924dc151822f5f7e79ae873"
  [libpciaccess-0.18.1.tar.xz]="57c7efbeceedefde006123a77a7bc825"
  [libxkbfile-1.1.3.tar.xz]="229708c15c9937b6e5131d0413474139"
  [libxshmfence-1.3.3.tar.xz]="9805be7e18f858bed9938542ed2905dc"
  [libXpresent-1.0.1.tar.xz]="bdd3ec17c6181fd7b26f6775886c730d"

  [mkfontscale-1.2.3.tar.xz]="7dcf5f702781bdd4aaff02e963a56270"

  [font-util-1.4.1.tar.xz]="a6541d12ceba004c0c1e3df900324642"
  [encodings-1.1.0.tar.xz]="a56b1a7f2c14173f71f010225fa131f1"
  [font-alias-1.0.5.tar.xz]="79f4c023e27d1db1dfd90d041ce89835"
  [font-adobe-utopia-type1-1.0.5.tar.xz]="546d17feab30d4e3abcf332b454f58ed"
  [font-bh-ttf-1.0.4.tar.xz]="063bfa1456c8a68208bf96a33f472bb1"
  [font-bh-type1-1.0.4.tar.xz]="51a17c981275439b85e15430a3d711ee"
  [font-ibm-type1-1.0.4.tar.xz]="00f64a84b6c9886040241e081347a853"
  [font-misc-ethiopic-1.0.5.tar.xz]="fe972eaf13176fa9aa7e74a12ecc801a"
  [font-xfree86-type1-1.0.5.tar.xz]="3b47fed2c032af3a32aad9acc1d25150"

  [libxcvt-0.1.3.tar.xz]="7fb9c51d33a680f724f34da41768b1d0"
  [pixman-0.46.4.tar.gz]="c08173c8e1d2cc79428d931c13ffda59"
  [xkeyboard-config-2.45.tar.xz]="cebc84ec99d3273e07aee8ecff3e3519"
  [xorg-server-21.1.18.tar.xz]="43225ddc1fd8d7ae7671c25ab6d1f927"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-3a-bronnen aanwezig en geverifieerd"
