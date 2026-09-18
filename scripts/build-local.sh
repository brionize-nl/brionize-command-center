#!/usr/bin/env bash
# Bouwt de wegwerp-Docker-sandbox en draait fase 1+2 (toolchain +
# temporary tools + chroot) erin. Zelfde pad als de GitHub Actions
# workflow — dit script is UITSLUITEND een bewuste, latere fallback-optie
# voor Brionize zelf op zijn eigen machine (zie BLUEPRINT.md/HANDOFF.md).
#
# NIET automatisch of "even ter validatie" draaien — dit bouwt een volledig
# LFS-basissysteem (kernel/glibc/gcc-compiles) en trekt de CPU/load flink
# aan gedurende (naar verwachting) tientallen minuten tot enkele uren.
# Validatie hoort bij GitHub Actions; dit script is er voor het moment dat
# Brionize zelf bewust besluit lokaal te bouwen (bv. als de CI-tijd/
# schijflimiet ooit echt knelt).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_TAG="brionize-lfs-toolchain:latest"
LFS_DIR="$REPO_ROOT/build/lfs"

mkdir -p "$LFS_DIR"

echo "==> Docker-image bouwen ($IMAGE_TAG)"
docker build -t "$IMAGE_TAG" -f "$REPO_ROOT/docker/Dockerfile.build" "$REPO_ROOT"

echo "==> Fase 1+2 (toolchain + temporary tools + chroot) draaien in container"
# --privileged: nodig voor de mount/chroot-stappen in fase 2 (hoofdstuk 7).
docker run --rm --privileged \
  -v "$LFS_DIR:/mnt/lfs" \
  -v "$REPO_ROOT/scripts:/opt/lfs/scripts:ro" \
  "$IMAGE_TAG" \
  bash -c "bash /opt/lfs/scripts/01-toolchain/run-all.sh && bash /opt/lfs/scripts/02-base-system/run-all.sh"
