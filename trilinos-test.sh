#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
cp -r "$HOME/rcs/debian/trilinos" "$ORIG_DIR"

VERSION=$(grep "Trilinos_VERSION " "$ORIG_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases bionic \
  --version-override "$VERSION~git$(date +"%Y%m%d%H%M")" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/trilinos-test \
  --debuild-params="-p$THIS_DIR/mygpg"
