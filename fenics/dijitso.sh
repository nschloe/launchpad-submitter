#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://nschloe@bitbucket.org/fenics-project/dijitso.git" "$ORIG_DIR"

VERSION=$(grep '__version__ =' "$ORIG_DIR/dijitso/__init__.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git@github.com:nschloe/debian-dijitso.git" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
