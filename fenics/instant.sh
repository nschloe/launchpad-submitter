#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/instant"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/instant.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

# VERSION=$(grep 'version =' "$ORIG_DIR/setup.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
# FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"
VERSION=$(grep 'version =' "$ORIG_DIR/setup.py" | sed 's/[^"]*"\([^"]\+\)".*/\1/')
FULL_VERSION="$VERSION-git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/instant-debian"
git -C "$CACHE" pull || git clone "https://salsa.debian.org/science-team/fenics/instant.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases bionic \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
