#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/mixxx/pristine/"
VERSION=$(grep "define VERSION" "$SOURCE_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
sed -i \"/0004-soundtouch.patch/d\" patches/ubuntu.series; \
sed -i \"/0005-hidapi.patch/d\" patches/ubuntu.series; \
sed -i \"/0006-opengles.patch/d\" patches/ubuntu.series; \
sed -i \"/1001-buildsystem.patch/d\" patches/ubuntu.series; \
sed -i \"s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g\" control; \
"
"$THIS_DIR/launchpad-submitter"\
  --name mixxx \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/mixxx/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty wily xenial \
  --version "$FULL_VERSION" \
  --ppas nschloe/mixxx-nightly \
  --submit-hashes-file "$THIS_DIR/mixxx-nightly.dat" \
  "$@"
