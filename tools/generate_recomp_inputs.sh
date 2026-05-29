#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -x ./N64Recomp ]]; then
  echo "Missing ./N64Recomp. Copy/build the host N64Recomp binary into the repo root." >&2
  exit 1
fi
if [[ ! -x ./RSPRecomp ]]; then
  echo "Missing ./RSPRecomp. Copy/build the host RSPRecomp binary into the repo root." >&2
  exit 1
fi

if [[ ! -f baserom.jp.z64 ]]; then
  echo "Missing baserom.jp.z64 (Chameleon Twist JP ROM, local-only; do not commit)." >&2
  exit 1
fi

./RSPRecomp aspMain.toml
./N64Recomp jp.rev0.toml

# CT1 also needs the native patch ELF recompiled into C sources before Gradle's
# full-runtime preflight runs. Prefer host LLVM tools; Android NDK clang does not
# support this MIPS patch build.
mkdir -p RecompiledPatches
make -C patches \
  CC="${PATCHES_C_COMPILER:-clang}" \
  LD="${PATCHES_LD:-ld.lld}" \
  OBJCOPY="${PATCHES_OBJCOPY:-llvm-objcopy}"
./N64Recomp patches.toml
file_to_c patches/patches.bin mm_patches_bin RecompiledPatches/patches_bin.c RecompiledPatches/patches_bin.h
