# Draait BUITEN chroot, als root (zelfde reden als 03a-d/04/hoofdstuk 8).
# Bronnen voor fase 5a: de volledige WebKitGTK-afhankelijkheidsketen +
# WebKitGTK zelf. Alles via BLFS 12.4 (chapter 25 Graphical Environment
# Libraries + chapter 42 Multimedia). Volledige bouwvolgorde +
# onderbouwing: zie BLUEPRINT.md "Fase 5a — WebKitGTK-afhankelijkheids-
# keten". Elke tarball-directorynaam vooraf geverifieerd via
# spot-download (zelfde discipline als 03a-d/04).
#
# NB: libyaml-0.2.5 (nodig voor Ruby) is AL aanwezig sinds fase 3b
# (voor PyYAML) — hier niet opnieuw gefetcht. GTK-3, Cairo, Mesa,
# CMake, libgudev, SQLite, libxml2 komen uit eerdere fasen.
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  # TLS-keten (glib-networking -> GnuTLS -> Nettle)
  [nettle-3.10.2.tar.gz]="https://ftp.gnu.org/gnu/nettle/nettle-3.10.2.tar.gz"
  [gnutls-3.8.10.tar.xz]="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.10.tar.xz"
  [glib-networking-2.80.1.tar.xz]="https://download.gnome.org/sources/glib-networking/2.80/glib-networking-2.80.1.tar.xz"

  # libsoup3-keten
  [libpsl-0.21.5.tar.gz]="https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz"
  [nghttp2-1.66.0.tar.xz]="https://github.com/nghttp2/nghttp2/releases/download/v1.66.0/nghttp2-1.66.0.tar.xz"
  [libsoup-3.6.5.tar.xz]="https://download.gnome.org/sources/libsoup/3.6/libsoup-3.6.5.tar.xz"

  # WebKitGTK's eigen directe Required-lijst (rest)
  [icu4c-77_1-src.tgz]="https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-src.tgz"
  [lcms2-2.17.tar.gz]="https://github.com/mm2/Little-CMS/releases/download/lcms2.17/lcms2-2.17.tar.gz"
  [libsecret-0.21.7.tar.xz]="https://download.gnome.org/sources/libsecret/0.21/libsecret-0.21.7.tar.xz"
  [libtasn1-4.20.0.tar.gz]="https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.20.0.tar.gz"
  [libwebp-1.6.0.tar.gz]="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.6.0.tar.gz"
  [openjpeg-2.5.3.tar.gz]="https://github.com/uclouvain/openjpeg/archive/v2.5.3/openjpeg-2.5.3.tar.gz"
  [ruby-3.4.5.tar.xz]="https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.5.tar.xz"
  [unifdef-2.12.tar.gz]="https://dotat.at/prog/unifdef/unifdef-2.12.tar.gz"
  [which-2.23.tar.gz]="https://ftp.gnu.org/gnu/which/which-2.23.tar.gz"

  # GStreamer-keten (gst-plugins-bad -> gst-plugins-base -> gstreamer)
  [gstreamer-1.26.5.tar.xz]="https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.26.5.tar.xz"
  [gst-plugins-base-1.26.5.tar.xz]="https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.26.5.tar.xz"
  [gst-plugins-bad-1.26.5.tar.xz]="https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.26.5.tar.xz"

  # WebKitGTK zelf
  [webkitgtk-2.48.5.tar.xz]="https://webkitgtk.org/releases/webkitgtk-2.48.5.tar.xz"
)

declare -A MD5=(
  [nettle-3.10.2.tar.gz]="b28bcbf6f045ff007940a9401673600d"
  [gnutls-3.8.10.tar.xz]="803c6f5c9cbe55c64fbb46690d329a77"
  [glib-networking-2.80.1.tar.xz]="405e6c058723217a1307ba8415615f9d"

  [libpsl-0.21.5.tar.gz]="870a798ee9860b6e77896548428dba7b"
  [nghttp2-1.66.0.tar.xz]="295c22437cc44e1634a2b82ea93df747"
  [libsoup-3.6.5.tar.xz]="181a474d783492e3f5f7cbfb047bcecd"

  [icu4c-77_1-src.tgz]="bc0132b4c43db8455d2446c3bae58898"
  [lcms2-2.17.tar.gz]="9f44275ee8ac122817e94fdc50ecce13"
  [libsecret-0.21.7.tar.xz]="7a938a802a3c17df441fbd0358866e99"
  [libtasn1-4.20.0.tar.gz]="930f71d788cf37505a0327c1b84741be"
  [libwebp-1.6.0.tar.gz]="cceb6447180f961473b181c9ef38b630"
  [openjpeg-2.5.3.tar.gz]="12ae257cb21738c41b5f6ca977d01081"
  [ruby-3.4.5.tar.xz]="7c46a4fbece1073bbef0d7d61bc030cc"
  [unifdef-2.12.tar.gz]="b225312c110cd2600ca7166bd0419751"
  [which-2.23.tar.gz]="1963b85914132d78373f02a84cdb3c86"

  [gstreamer-1.26.5.tar.xz]="2585de32253e8b159cbddf92b21b0261"
  [gst-plugins-base-1.26.5.tar.xz]="b7213409f50916a7f8e3c5bb59ea3b2d"
  [gst-plugins-bad-1.26.5.tar.xz]="b4d99dc0fddc0a54d96b0389830f283f"

  [webkitgtk-2.48.5.tar.xz]="23e26bc4e30b80462cb1030fab352409"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle fase-5a-bronnen aanwezig en geverifieerd"
