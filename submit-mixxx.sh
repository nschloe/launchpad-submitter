#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat "$HOME/.ssh/agent/info")

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/mixxx/pristine/"
VERSION=$(grep "define VERSION" "$SOURCE_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

DEBIAN_PREPARE="
sed -i \"/0001-update_configure.patch/d\" patches/series; \
sed -i \"/0004-soundtouch.patch/d\" patches/series; \
sed -i \"/1001-buildsystem.patch/d\" patches/series; \
sed -i \"/9001-waveformsignalcolors_fix.patch/d\" patches/series; \
"

"$THIS_DIR/launchpad-submitter"\
  --name mixxx \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/mixxx/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty vivid wily xenial \
  --version "$VERSION" \
  --ppas nschloe/mixxx-nightly \
  --submit-hashes-file "$THIS_DIR/mixxx-nightly.dat" \
  "$@"
