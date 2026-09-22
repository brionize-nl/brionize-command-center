#!/bin/bash
# BLFS 12.4 — LLVM-20.1.8. Draait binnen chroot, als root.
# Nodig voor Mesa's llvmpipe-driver (zie Beslislog 2026-09-22). Dit is
# verreweg het zwaarste pakket in fase 3b (boek schat 13 SBU met
# parallelism=8, 4.7 GB schijfruimte) — reken op een aanzienlijk
# langere CI-tijd dan al het andere in 03b samen.
#
# BEWUST MINIMAAL t.o.v. het boek:
# - GEEN Clang (boek: "Recommended Download", niet nodig voor Mesa/
#   llvmpipe) — clang-tarball wordt niet eens gefetcht.
# - GEEN Compiler-RT (boek: "Optional Download") — evenmin gefetcht.
# - GEEN testsuite (LLVM_INCLUDE_TESTS=OFF) — scheelt aanzienlijke tijd
#   en de eerder genoemde 23 GB extra schijfruimte voor tests.
# - GEEN benchmarks/examples.
# - LLVM_TARGETS_TO_BUILD="X86" i.p.v. het boek's "host;AMDGPU" — wij
#   willen alleen llvmpipe (CPU-software-rasterizer, architectuur-
#   onafhankelijk van GPU-merk), geen AMDGPU-codegen-backend nodig.
set -euo pipefail
cd /sources
tar -xf llvm-20.1.8.src.tar.xz
cd llvm-20.1.8.src

# De twee extra tarballs zijn een hard vereist onderdeel van LLVM's
# eigen bouwsysteem (geen los pakket) — letterlijk boek-instructie.
tar -xf ../llvm-cmake-20.1.8.src.tar.xz
tar -xf ../llvm-third-party-20.1.8.src.tar.xz
sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@cmake-20.1.8.src@' \
    -i CMakeLists.txt
sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@third-party-20.1.8.src@' \
    -i cmake/modules/HandleLLVMOptions.cmake

mkdir -v build
cd build

CC=gcc CXX=g++                               \
cmake -D CMAKE_INSTALL_PREFIX=/usr           \
    -D CMAKE_SKIP_INSTALL_RPATH=ON         \
    -D LLVM_ENABLE_FFI=ON                  \
    -D CMAKE_BUILD_TYPE=Release            \
    -D LLVM_BUILD_LLVM_DYLIB=ON            \
    -D LLVM_LINK_LLVM_DYLIB=ON             \
    -D LLVM_ENABLE_RTTI=ON                 \
    -D LLVM_TARGETS_TO_BUILD="X86"         \
    -D LLVM_BINUTILS_INCDIR=/usr/include   \
    -D LLVM_INCLUDE_BENCHMARKS=OFF         \
    -D LLVM_INCLUDE_TESTS=OFF              \
    -D LLVM_INCLUDE_EXAMPLES=OFF           \
    -W no-dev -G Ninja ..
ninja
ninja install

cd /sources
rm -rf llvm-20.1.8.src
echo "==> LLVM (minimaal, X86-only) klaar"
