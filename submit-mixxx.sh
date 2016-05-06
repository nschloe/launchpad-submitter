#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/mixxx/pristine/"
cd "$SOURCE_DIR" && git pull
VERSION=$(grep "define VERSION" "$SOURCE_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/mixxx/debian/"
cd "$DEBIAN_DIR" && git pull
sed -i "/0004-soundtouch.patch/d" patches/ubuntu.series
sed -i "/0005-hidapi.patch/d" patches/ubuntu.series
sed -i "/0006-opengles.patch/d" patches/ubuntu.series
sed -i "/1001-buildsystem.patch/d" patches/ubuntu.series
sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" control

DIR="/tmp/mixxx"
rm -rf "$DIR"
"$THIS_DIR/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$THIS_DIR/launchpad-submit"\
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/mixxx-nightly \
  --submit-id 'Nico Schlömer <nico.schloemer@gmail.com>' \
  "$@"
