#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$("$HOME/rcs/launchpad-tools/create-debian-repo" \
   --source "git@github.com:mixxxdj/mixxx.git" \
   --debian "git://anonscm.debian.org/git/pkg-multimedia/mixxx.git"
  )

VERSION=$(grep "define VERSION" "$DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

sed -i "/0004-soundtouch.patch/d" "$DIR/debian/patches/ubuntu.series"
sed -i "/0005-hidapi.patch/d" "$DIR/debian/patches/ubuntu.series"
sed -i "/0006-opengles.patch/d" "$DIR/debian/patches/ubuntu.series"
sed -i "/1001-buildsystem.patch/d" "$DIR/debian/patches/ubuntu.series"
sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" "$DIR/debian/control"
sed -i "s/scons,/scons, libupower-glib-dev,/g" "$DIR/debian/control"
cd "$DIR" && git commit -a -m "update patches"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --ppa nschloe/mixxx-nightly \
  --version "$FULL_VERSION" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  --debuild-params="-p$THIS_DIR/mygpg" \
  "$@"

rm -rf "$DIR"
