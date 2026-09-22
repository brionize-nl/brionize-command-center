# Draait BUITEN chroot, als root (zelfde reden als 03a/hoofdstuk 8).
# Bronnen voor fase 3b (BLFS 12.4): de GTK3-supporting-stack — GLib+
# GObject-Introspection, de HarfBuzz/FreeType/Fontconfig-herbouwlus,
# Cairo/Pango, dbus/at-spi2-core, gdk-pixbuf, Mesa (llvmpipe-only) +
# LLVM, libepoxy en GTK3 zelf. Volledige bouwvolgorde + onderbouwing:
# zie BLUEPRINT.md "Fase 3b — GTK3-supporting-stack: volledige
# bouwvolgorde". URL's/MD5's letterlijk van de officiële BLFS
# 12.4-boekpagina's (of, voor GObject-Introspection/Python-modules/
# LLVM-cmake/third-party, van de exacte "Additional Downloads"-regels
# op de betreffende paginas).
#
# NB: freetype-2.13.3.tar.xz en fontconfig-2.17.1.tar.xz worden HIER
# niet opnieuw gefetcht — die tarballs staan al in $LFS/sources sinds
# 03a (fetch_verified() haalt niets dubbel op) en worden in 03b alleen
# opnieuw uitgepakt/herbouwd (zie 15-freetype-rebuild.sh/
# 16-fontconfig-rebuild.sh).
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  [pcre2-10.45.tar.bz2]="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.45/pcre2-10.45.tar.bz2"
  [libpng-1.6.50.tar.xz]="https://downloads.sourceforge.net/libpng/libpng-1.6.50.tar.xz"
  [yaml-0.2.5.tar.gz]="https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz"

  # Python-modules (BLFS "Python Modules"-pagina, pip3-wheel-patroon)
  [mako-1.3.10.tar.gz]="https://files.pythonhosted.org/packages/source/M/Mako/mako-1.3.10.tar.gz"
  [cython-3.1.3.tar.gz]="https://github.com/cython/cython/releases/download/3.1.3/cython-3.1.3.tar.gz"
  [pyyaml-6.0.2.tar.gz]="https://files.pythonhosted.org/packages/source/P/PyYAML/pyyaml-6.0.2.tar.gz"

  # docutils — levert rst2man; toegevoegd na een terugkerend patroon
  # (Anti-Patch-Loop): meerdere latere pakketten (GLib, gdk-pixbuf, ...)
  # verwachten dit voor man-pages/documentatie op boek-standaardinstellingen.
  [docutils-0.21.2.tar.gz]="https://files.pythonhosted.org/packages/source/d/docutils/docutils-0.21.2.tar.gz"

  # GLib + GObject-Introspection (twee-staps-bootstrap, zie 07-09)
  [glib-2.84.4.tar.xz]="https://download.gnome.org/sources/glib/2.84/glib-2.84.4.tar.xz"
  [gobject-introspection-1.84.0.tar.xz]="https://download.gnome.org/sources/gobject-introspection/1.84/gobject-introspection-1.84.0.tar.xz"

  [libxml2-2.14.5.tar.xz]="https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.5.tar.xz"
  [shared-mime-info-2.4.tar.gz]="https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/2.4/shared-mime-info-2.4.tar.gz"
  [dbus-1.16.2.tar.xz]="https://dbus.freedesktop.org/releases/dbus/dbus-1.16.2.tar.xz"
  [gsettings-desktop-schemas-48.0.tar.xz]="https://download.gnome.org/sources/gsettings-desktop-schemas/48/gsettings-desktop-schemas-48.0.tar.xz"

  [harfbuzz-11.4.1.tar.xz]="https://github.com/harfbuzz/harfbuzz/releases/download/11.4.1/harfbuzz-11.4.1.tar.xz"
  [fribidi-1.0.16.tar.xz]="https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz"
  [cairo-1.18.4.tar.xz]="https://www.cairographics.org/releases/cairo-1.18.4.tar.xz"
  [pango-1.56.4.tar.xz]="https://download.gnome.org/sources/pango/1.56/pango-1.56.4.tar.xz"

  [cmake-4.1.0.tar.gz]="https://cmake.org/files/v4.1/cmake-4.1.0.tar.gz"
  [libjpeg-turbo-3.0.1.tar.gz]="https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-3.0.1.tar.gz"
  [gdk-pixbuf-2.42.12.tar.xz]="https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.12.tar.xz"
  [at-spi2-core-2.56.4.tar.xz]="https://download.gnome.org/sources/at-spi2-core/2.56/at-spi2-core-2.56.4.tar.xz"

  # LLVM (minimaal: alleen kernbibliotheken, geen Clang/Compiler-RT —
  # zie BLUEPRINT.md). De twee extra tarballs zijn een hard vereist
  # onderdeel van LLVM's eigen bouwsysteem, geen los pakket.
  [llvm-20.1.8.src.tar.xz]="https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/llvm-20.1.8.src.tar.xz"
  [llvm-cmake-20.1.8.src.tar.xz]="https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-cmake-20.1.8.src.tar.xz"
  [llvm-third-party-20.1.8.src.tar.xz]="https://anduin.linuxfromscratch.org/BLFS/llvm/llvm-third-party-20.1.8.src.tar.xz"

  [mesa-25.1.8.tar.xz]="https://mesa.freedesktop.org/archive/mesa-25.1.8.tar.xz"
  [libepoxy-1.5.10.tar.xz]="https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz"
  [gtk-3.24.50.tar.xz]="https://download.gnome.org/sources/gtk/3.24/gtk-3.24.50.tar.xz"
)

declare -A MD5=(
  [pcre2-10.45.tar.bz2]="f71abbe1b5adf25cd9af5d26ef223b66"
  [libpng-1.6.50.tar.xz]="e583e61455c4f40d565d85c0e9a2fbf9"
  [yaml-0.2.5.tar.gz]="bb15429d8fb787e7d3f1c83ae129a999"

  [mako-1.3.10.tar.gz]="c9dfb2bf42827459dd505c60f2262a7c"
  [cython-3.1.3.tar.gz]="f508595cc0951a77b70c07100df1b4ff"
  [pyyaml-6.0.2.tar.gz]="9600ee49b2b4e1a0237cf4173b6dc594"
  [docutils-0.21.2.tar.gz]="c4064e1e0e3cd142951fd2b95b830874"

  [glib-2.84.4.tar.xz]="5655d0ff809b98dd77c02490609fadde"
  [gobject-introspection-1.84.0.tar.xz]="2a62fb1c584616a8ebcd9dd4d045f27e"

  [libxml2-2.14.5.tar.xz]="59aac4e5d1d350ba2c4bddf1f7bc5098"
  [shared-mime-info-2.4.tar.gz]="aac56db912b7b12a04fb0018e28f2f36"
  [dbus-1.16.2.tar.xz]="97832e6f0a260936d28536e5349c22e5"
  [gsettings-desktop-schemas-48.0.tar.xz]="e5721d5c378cb5fb4817943357b96ea5"

  [harfbuzz-11.4.1.tar.xz]="0f2f8fe443032019b5ca9598c8e2b912"
  [fribidi-1.0.16.tar.xz]="333ad150991097a627755b752b87f9ff"
  [cairo-1.18.4.tar.xz]="db575fb41bbda127e0147e401f36f8ac"
  [pango-1.56.4.tar.xz]="3db267bc07bfd96615c652e9187b85b5"

  [cmake-4.1.0.tar.gz]="80ae27faba5068c8ec12c77bf00e6db3"
  [libjpeg-turbo-3.0.1.tar.gz]="1fdc6494521a8724f5f7cf39b0f6aff3"
  [gdk-pixbuf-2.42.12.tar.xz]="f986fdbba5ec6233c96f8b6535811780"
  [at-spi2-core-2.56.4.tar.xz]="1bdef0e54532c4f3f004d7e2d40e256a"

  [llvm-20.1.8.src.tar.xz]="78040509eb91309b4ec2edfe12cd20d8"
  [llvm-cmake-20.1.8.src.tar.xz]="5bfb8f4b4a2b3ccffca0d2406e4cdcc6"
  [llvm-third-party-20.1.8.src.tar.xz]="2ffd8624b3cbddf55a4e74a7d8ea89fa"

  [mesa-25.1.8.tar.xz]="fe3eb39e8a3c6fbb36eb3da57be022e7"
  [libepoxy-1.5.10.tar.xz]="10c635557904aed5239a4885a7c4efb7"
  [gtk-3.24.50.tar.xz]="0b3c6d1d6fc321a32624e65750b60f5d"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-3b-bronnen aanwezig en geverifieerd"
