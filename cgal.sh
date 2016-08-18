#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/CGAL/cgal.git" "$ORIG_DIR"

MAJOR=$(cat "$ORIG_DIR/Maintenance/release_building/MAJOR_NUMBER")
MINOR=$(cat "$ORIG_DIR/Maintenance/release_building/MINOR_NUMBER")
PATCH=$(cat "$ORIG_DIR/Maintenance/release_building/BUGFIX_NUMBER")
VERSION="$MAJOR.$MINOR.$PATCH"
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone "git@github.com:nschloe/cgal-debian.git" "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety \
  --ppa nschloe/cgal-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
