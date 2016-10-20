#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/Unidata/netcdf-cxx4.git" "$ORIG_DIR"

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
  "git://anonscm.debian.org/git/pkg-grass/netcdf-cxx.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/netcdf-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
