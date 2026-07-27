#!/usr/bin/env bash
# build-hekate.sh — 使用 devkitpro/devkita64 编译 hekate
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

IMAGE="${HEKATE_DOCKER_IMAGE:-devkitpro/devkita64}"
JOBS="${JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}"
TARGET="${1:-all}"

if ! command -v docker >/dev/null 2>&1; then
  echo "错误: 未找到 docker，请先安装 Docker。" >&2
  exit 1
fi

echo "==> 镜像:  $IMAGE"
echo "==> 目标:  $TARGET"
echo "==> 并行:  $JOBS"
echo "==> 目录:  $ROOT"

docker run --rm \
  -v "$ROOT:/src" \
  -w /src \
  -e DEVKITPRO=/opt/devkitpro \
  -e DEVKITARM=/opt/devkitpro/devkitARM \
  "$IMAGE" \
  make -j"$JOBS" "$TARGET"

if [[ "$TARGET" != "clean" ]]; then
  echo
  echo "产物:"
  ls -lh output/ 2>/dev/null || true
  find output loader -maxdepth 2 -type f -name '*.bin' 2>/dev/null | sort
fi
