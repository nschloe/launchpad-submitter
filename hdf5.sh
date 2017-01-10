#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git" \
  "$ORIG_DIR"
# note that libtool-bin is needed here
cd "$ORIG_DIR" && ./autogen.sh

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/.*\[\([0-9][0-9\.]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
  "git://anonscm.debian.org/git/pkg-grass/hdf5.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases yakkety zesty \
  --ppa nschloe/hdf5-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --debuild-params="-p$THIS_DIR/mygpg"
