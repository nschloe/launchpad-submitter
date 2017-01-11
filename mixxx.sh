#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/mixxxdj/mixxx.git" \
  "$ORIG_DIR"

VERSION=$(grep "define MIXXX_VERSION" "$ORIG_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone \
  --subdirectory=debian/ \
  "git://anonscm.debian.org/git/pkg-multimedia/mixxx.git" \
  "$DEBIAN_DIR"

sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" "$DEBIAN_DIR/control"
sed -i "s/scons,/scons, libupower-glib-dev,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --ppa nschloe/mixxx-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"
