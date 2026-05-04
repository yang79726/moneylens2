#!/bin/bash
# Bundle MoneyLens app for offline Android use
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SCRIPT_DIR/app/src/main/assets/moneylens"

echo "=== Step 1: Create assets directory ==="
mkdir -p "$ASSETS_DIR"

echo "=== Step 2: Download CDN libraries ==="
download_lib() {
  local url1="$1" url2="$2" output="$3"
  echo "  Downloading $output..."
  if command -v curl &>/dev/null; then
    curl -sSL --connect-timeout 15 "$url1" -o "$output" 2>/dev/null || \
    curl -sSL --connect-timeout 15 "$url2" -o "$output" 2>/dev/null || \
    echo "  WARNING: Failed to download $output"
  else
    wget -q "$url1" -O "$output" 2>/dev/null || \
    wget -q "$url2" -O "$output" 2>/dev/null || \
    echo "  WARNING: Failed to download $output"
  fi
}

download_lib \
  "https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js" \
  "https://unpkg.com/echarts@5.5.0/dist/echarts.min.js" \
  "$ASSETS_DIR/echarts.min.js"

download_lib \
  "https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js" \
  "https://unpkg.com/xlsx@0.18.5/dist/xlsx.full.min.js" \
  "$ASSETS_DIR/xlsx.full.min.js"

echo "=== Step 3: Build offline index.html ==="
INDEX_HTML="$ROOT_DIR/index.html"

if [ ! -f "$INDEX_HTML" ]; then
  echo "ERROR: index.html not found at $INDEX_HTML"
  exit 1
fi

# Replace CDN URLs with local asset references
sed 's|https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js|echarts.min.js|g' "$INDEX_HTML" | \
sed 's|https://unpkg.com/echarts@5.5.0/dist/echarts.min.js|echarts.min.js|g' | \
sed 's|https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js|xlsx.full.min.js|g' | \
sed 's|https://unpkg.com/xlsx@0.18.5/dist/xlsx.full.min.js|xlsx.full.min.js|g' \
  > "$ASSETS_DIR/index.html"

echo "  Offline index.html created ($(wc -c < "$ASSETS_DIR/index.html") bytes)"
ls -lh "$ASSETS_DIR/"
echo "=== Bundle complete! ==="
