#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/openblas"
git -C "$CACHE" pull || git clone "https://github.com/xianyi/OpenBLAS.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'set(OpenBLAS_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(OpenBLAS_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(OpenBLAS_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/openblas-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/openblas.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# xenial: Missing build dependencies: debhelper (>= 10), liblapack-pic (>=
# 3.7.0),
# zesty liblapack-pic (>= 3.7.1)
launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases artful bionic \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/openblas-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
