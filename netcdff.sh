#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/Unidata/netcdf-fortran.git" \
  "$ORIG_DIR"

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
  "git://anonscm.debian.org/git/pkg-grass/netcdf-fortran.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/netcdf-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
