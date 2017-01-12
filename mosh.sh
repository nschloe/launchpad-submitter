#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/mobile-shell/mosh.git" \
  "$ORIG_DIR"

VERSION=$(grep AC_INIT "$ORIG_DIR/configure.ac" | sed "s/[^0-9]*\([^]]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/mosh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
