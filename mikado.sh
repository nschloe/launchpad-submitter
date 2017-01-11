#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

DIR="$TMP_DIR"
clone --ignore-hidden "https://github.com/nschloe/mikado.git" "$DIR"

MAJOR=$(grep "set(Mikado_MAJOR_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep "set(Mikado_MINOR_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep "set(Mikado_PATCH_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH"

launchpad-submit \
  --orig-dir "$DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/mikado-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
