#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/fenics"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/fenics.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

# VERSION = "2017.2.0.dev0"
VERSION=$(grep 'VERSION = "' "$ORIG_DIR/setup.py" | sed 's/[^0-9]*\([0-9]\+\.[0-9]\.[0-9]\+\).*/\1/')
FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"

CACHE="$HOME/.cache/repo/fenics-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/fenics.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --ubuntu-releases bionic \
  --debuild-params="-p$THIS_DIR/../mygpg"

