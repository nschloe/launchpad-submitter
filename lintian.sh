#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/lintian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/lintian/lintian.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(head -n 1 "$ORIG_DIR/debian/changelog" | sed 's/^[^0-9]*\([0-9\.]*\).*/\1/')
GIT_VERSION="$VERSION+git$(date +"%Y%m%d")"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful bionic \
  --version-override "$GIT_VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/lintian-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
