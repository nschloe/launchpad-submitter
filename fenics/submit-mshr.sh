#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/mshr/upstream/"
# SOURCE_DIR="$HOME/software/fenics/mshr/source-nschloe/"

MAJOR=$(grep 'MSHR_VERSION_MAJOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'MSHR_VERSION_MINOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'MSHR_VERSION_MICRO ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
sed -i \"/mshrable/d\" libmshr-dev.install; \
"
"$THIS_DIR/../launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/fenics/mshr/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/mshr-submit-hash.dat" \
  "$@"
