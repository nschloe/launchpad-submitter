#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
clone "https://github.com/nschloe/mikado.git" "$DIR"

MAJOR=$(grep "set(Mikado_MAJOR_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep "set(Mikado_MINOR_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep "set(Mikado_PATCH_VERSION " "$DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH"

launchpad-submit \
  --orig "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/mikado-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$DIR"
