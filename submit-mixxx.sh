#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

$THIS_DIR/launchpad-submitter \
  --name mixxx \
  --resubmission 1 \
  --source-dir "$HOME/software/mixxx/pristine/" \
  --debian-dir "$HOME/rcs/debian-packages/mixxx/debian/" \
  --ubuntu-releases trusty vivid wily xenial \
  --patches-blacklist \
    0001-update_configure.patch \
    0004-soundtouch.patch \
    1001-buildsystem.patch \
    9001-waveformsignalcolors_fix.patch \
  --version-getter 'grep "define VERSION" src/defs_version.h | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/mixxx-nightly \
  --submit-hashes-file "$THIS_DIR/mixxx-nightly.dat" \
  "$@"
