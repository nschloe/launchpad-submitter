#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git@github.com:mixxxdj/mixxx.git" \
   "$ORIG_DIR"

VERSION=$(grep "define VERSION" "$ORIG_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git://anonscm.debian.org/git/pkg-multimedia/mixxx.git" \
   "$DEBIAN_DIR"

sed -i "/0004-soundtouch.patch/d" "$DEBIAN_DIR/debian/patches/ubuntu.series"
sed -i "/0004-soundtouch.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/0005-hidapi.patch/d" "$DEBIAN_DIR/debian/patches/ubuntu.series"
sed -i "/0005-hidapi.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/0006-opengles.patch/d" "$DEBIAN_DIR/debian/patches/ubuntu.series"
sed -i "/0006-opengles.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/1001-buildsystem.patch/d" "$DEBIAN_DIR/debian/patches/ubuntu.series"
sed -i "/1001-buildsystem.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" "$DEBIAN_DIR/debian/control"
sed -i "s/scons,/scons, libupower-glib-dev,/g" "$DEBIAN_DIR/debian/control"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --ppa nschloe/mixxx-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  --debuild-params="-p$THIS_DIR/mygpg" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
