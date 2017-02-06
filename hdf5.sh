#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/hdf5"
git -C "$CACHE" pull || git clone "https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

cd "$ORIG_DIR" && ./autogen.sh

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/.*\[\([0-9][0-9\.]*\).*/\1/")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/hdf5-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/pkg-grass/hdf5.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases yakkety zesty \
  --ppa nschloe/hdf5-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --debuild-params="-p$THIS_DIR/mygpg"
