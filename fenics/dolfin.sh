#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://bitbucket.org/fenics-project/dolfin.git" \
  "$ORIG_DIR"

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
   "git://anonscm.debian.org/git/debian-science/packages/fenics/dolfin.git" \
   "$DEBIAN_DIR"

# sed -i "/slepc-dev/d"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
