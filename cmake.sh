#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "git@github.com:Kitware/CMake.git" "$ORIG_DIR"

MAJOR=$(grep 'set(CMake_VERSION_MAJOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(CMake_VERSION_MINOR ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(CMake_VERSION_RC ' "$ORIG_DIR/Source/CMakeVersion.cmake" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/pkg-cmake/cmake.git" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/cmake-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"