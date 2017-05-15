#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/fiat"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/fiat.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep '__version__ =' "$ORIG_DIR/FIAT/__init__.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/fiat-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/fiat.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
