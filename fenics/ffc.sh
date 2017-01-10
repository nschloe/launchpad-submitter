#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://bitbucket.org/fenics-project/ffc.git" \
  "$ORIG_DIR"

VERSION=$(grep '__version__ =' "$ORIG_DIR/ffc/__init__.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
   "git://anonscm.debian.org/git/debian-science/packages/fenics/ffc.git" \
   "$DEBIAN_DIR"

sed -i "/ufc-1.pc/d" "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
