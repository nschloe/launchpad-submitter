#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://svn.hdfgroup.uiuc.edu/hdf5/trunk/" "$ORIG_DIR"

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/.*\[\([0-9][0-9\.]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone "git://anonscm.debian.org/git/pkg-grass/hdf5.git" "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety \
  --ppa nschloe/hdf5-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
