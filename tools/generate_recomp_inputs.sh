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

# CT1 has native patch recompilation sources generated through the CMake PatchesBin flow.
# Build-time CMake will regenerate RecompiledPatches/patches.c and patches_bin.c from patches.toml
# after patches/patches.elf exists.
