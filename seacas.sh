#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
clone "git@github.com:gdsjaar/seacas.git" "$DIR"

VERSION=$(grep "SEACASProj_VERSION " "$DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --orig "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/seacas-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$DIR"
