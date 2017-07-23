#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/scipy"
git -C "$CACHE" pull || git clone "https://github.com/scipy/scipy.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'MAJOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'MINOR' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'MICRO' "$ORIG_DIR/setup.py" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

CACHE="$HOME/.cache/repo/scipy-debian"
git -C "$CACHE" pull || git clone "git://anonscm.debian.org/git/python-modules/packages/python-scipy.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial zesty artful \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d%H%M")" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/scipy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
