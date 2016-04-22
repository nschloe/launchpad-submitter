#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/dolfin/pristine/"
MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
"
"$THIS_DIR/../launchpad-submitter" \
  --name fenics \
  --debian-dir "$HOME/software/debian-science-fenics/github/fenics/trunk/debian/" \
  --ubuntu-releases xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/fenics-submit-hash.dat" \
  "$@"
