#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/numpy/numpy.git" \
  "$ORIG_DIR"
cd "$ORIG_DIR" && git submodule init && git submodule update

MAJOR=$(grep 'MAJOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'MINOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'MICRO' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR="$TMP_DIR/orig/debian"
clone \
  --subdirectory=debian/ \
  "git://anonscm.debian.org/git/python-modules/packages/python-numpy.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/numpy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
