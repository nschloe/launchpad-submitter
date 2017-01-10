#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://bitbucket.org/fenics-project/mshr.git" \
  "$ORIG_DIR"

MAJOR=$(grep 'MSHR_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'MSHR_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'MSHR_VERSION_MICRO ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
   "git://anonscm.debian.org/git/debian-science/packages/fenics/mshr.git" \
   "$DEBIAN_DIR"

sed -i "/mshrable/d" "$DEBIAN_DIR/debian/libmshr-dev.install"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
