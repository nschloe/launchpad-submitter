#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

DIR="$TMP_DIR"
clone --ignore-hidden \
  "https://bitbucket.org/fathomteam/moab.git" \
  "$DIR"

VERSION=$(grep AC_INIT "$DIR/configure.ac" | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --work-dir "$DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/moab-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
