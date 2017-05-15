#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/mixxx"
git -C "$CACHE" pull || git clone "https://github.com/mixxxdj/mixxx.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep "define MIXXX_VERSION" "$ORIG_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/mixxx-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/pkg-multimedia/mixxx.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" "$DEBIAN_DIR/control"
sed -i "s/scons,/scons, libupower-glib-dev,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty artful \
  --ppa nschloe/mixxx-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"
