#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/fiat"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/fiat.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

# VERSION=$(grep 'version =' "$ORIG_DIR/setup.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
# FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"
VERSION=$(grep 'version =' "$ORIG_DIR/setup.py" | sed 's/[^"]*"\([^"]\+\)".*/\1/')
FULL_VERSION="$VERSION-git$(date +"%Y%m%d%H%M")"

CACHE="$HOME/.cache/repo/fiat-debian"
git -C "$CACHE" pull || git clone "https://salsa.debian.org/science-team/fenics/fiat.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/pkg_resources.get_distribution(\"FIAT\").version/'$VERSION'/" "$ORIG_DIR/FIAT/__init__.py"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases bionic \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
