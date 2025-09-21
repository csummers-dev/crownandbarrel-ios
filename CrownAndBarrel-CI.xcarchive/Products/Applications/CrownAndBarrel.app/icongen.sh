#!/usr/bin/env bash
set -euo pipefail

# Usage: ./AppResources/icongen.sh AppResources/AppIcon-1024.png
# Generates iPhone-only icons into Assets.xcassets/AppIcon.appiconset
# Requires: sips (preinstalled on macOS)

SRC=${1:-}
if [[ -z "${SRC}" ]]; then
  echo "Usage: $0 path/to/AppIcon-1024.png" >&2
  exit 1
fi
if [[ ! -f "${SRC}" ]]; then
  echo "Source image not found: ${SRC}" >&2
  exit 1
fi

DEST="AppResources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "${DEST}"

# ios-marketing (App Store)
cp "${SRC}" "${DEST}/Icon-1024.png"

# Helper: resize with sips width=HEIGHT since icons are square
resize() {
  local size=$1; local name=$2
  sips -Z "${size}" "${SRC}" --out "${DEST}/${name}" >/dev/null
}

# iPhone
resize 40  Icon-20@2x.png   # 20pt @2x
resize 60  Icon-20@3x.png   # 20pt @3x
resize 58  Icon-29@2x.png   # 29pt @2x
resize 87  Icon-29@3x.png   # 29pt @3x
resize 80  Icon-40@2x.png   # 40pt @2x
resize 120 Icon-40@3x.png   # 40pt @3x
resize 120 Icon-60@2x.png   # 60pt @2x
resize 180 Icon-60@3x.png   # 60pt @3x

echo "App icons generated in ${DEST}"
