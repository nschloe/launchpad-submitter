#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/scipy/scipy.git" "$ORIG_DIR"

MAJOR=$(grep 'MAJOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'MINOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'MICRO' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/python-modules/packages/python-scipy.git" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/scipy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
