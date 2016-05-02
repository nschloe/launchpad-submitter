#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/swig/swig-3.0.8/"
# FULL_VERSION="3.0.8-$(date +"%Y%m%d%H%M%S")"
FULL_VERSION="3.0.8-ppa0"

"$THIS_DIR/launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/swig/debian/" \
  --ubuntu-releases trusty wily \
  --version "$FULL_VERSION" \
  --ppas nschloe/swig-backports \
  --submit-hashes-file "$THIS_DIR/swig-submit-hash.dat" \
  "$@"
