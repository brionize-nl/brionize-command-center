#!/bin/bash
# Supabase CLI v2.117.0. Draait binnen chroot, als root. Officiële
# prebuilt Linux-x86_64-tarball (GitHub Releases).
set -euo pipefail
cd /sources
mkdir -p supabase-cli-extract
tar -xf supabase_2.117.0_linux_amd64.tar.gz -C supabase-cli-extract
install -v -m755 supabase-cli-extract/supabase /usr/local/bin/supabase
rm -rf supabase-cli-extract

echo "==> Supabase CLI klaar: $(supabase --version)"
