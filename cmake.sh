#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/cmake"
git -C "$CACHE" pull || git clone "https://github.com/Kitware/CMake.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'set(CMake_VERSION_MAJOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(CMake_VERSION_MINOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(CMake_VERSION_RC ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

CACHE="$HOME/.cache/repo/cmake-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/pkg-cmake/cmake.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_DIR="$ORIG_DIR/debian"
sed -i "s/Build-Depends:/Build-Depends: librhash-dev,/" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION+git$(date +"%Y%m%d")" \
  --version-append-hash \
  --ppa nschloe/cmake-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
