#!/bin/bash
# LFS 12.4 hoofdstuk 8.57 — Meson-1.8.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf meson-1.8.3.tar.gz
cd meson-1.8.3

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources
rm -rf meson-1.8.3
echo "==> Meson klaar"
