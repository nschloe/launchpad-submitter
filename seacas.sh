#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

DIR=="$TMP_DIR"
clone --ignore-hidden \
  "https://github.com/gsjaardema/seacas.git" \
  "$DIR"

VERSION=$(grep "SEACASProj_VERSION " "$DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --orig-dir "$DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/seacas-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
