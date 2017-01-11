#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/Kitware/CMake.git" \
  "$ORIG_DIR"

MAJOR=$(grep 'set(CMake_VERSION_MAJOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(CMake_VERSION_MINOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(CMake_VERSION_RC ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR="$TMP_DIR/debian"
clone \
  --subdirectory=debian/ \
  "https://anonscm.debian.org/git/pkg-cmake/cmake.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/cmake-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
