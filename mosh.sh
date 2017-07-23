#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/mosh"
git -C "$CACHE" pull || git clone "https://github.com/mobile-shell/mosh.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep AC_INIT "$ORIG_DIR/configure.ac" | sed "s/[^0-9]*\([^]]*\).*/\1/")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/mosh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
