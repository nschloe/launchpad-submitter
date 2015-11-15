#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/seacas/source-upstream/"
VERSION=$(grep "SEACASProj_VERSION " "$SOURCE_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$THIS_DIR/launchpad-submitter" \
  --name seacas \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases trusty vivid wily xenial \
  --version "$FULL_VERSION" \
  --ppas nschloe/seacas-nightly \
  --submit-hashes-file "$THIS_DIR/seacas-submit-hash1.dat" \
  "$@"
