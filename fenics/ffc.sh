#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone \
  "git@bitbucket.org:fenics-project/ffc.git" \
  "$ORIG_DIR"

VERSION=$(grep '__version__ =' "$ORIG_DIR/ffc/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/debian-science/packages/fenics/ffc.git" \
   "$DEBIAN_DIR"

sed -i "/fix-ufc-config.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/ufc-1.pc/d" "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
