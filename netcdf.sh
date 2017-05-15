#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/netcdf"
git -C "$CACHE" pull || git clone "https://github.com/Unidata/netcdf-c.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep "^AC_INIT" "$ORIG_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/netcdf-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/pkg-grass/netcdf.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases precise trusty xenial yakkety zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/netcdf-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
