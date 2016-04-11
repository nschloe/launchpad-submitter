#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/trilinos/source-upstream/"
VERSION=$(grep "Trilinos_VERSION " "$SOURCE_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/trilinos/debian/"

# copy over debian dir and replace respective lines
DEBIAN_PREPARE="
sed -i '/libhdf5-openmpi-dev/d' control; \
sed -i '/HDF5/d' rules; \
sed -i '/libsuperlu-dev/d' control; \
sed -i '/SuperLU/d' rules;
"

# trusty
"$THIS_DIR/launchpad-submitter" \
  --name trilinos \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty \
  --version "$FULL_VERSION" \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos1-submit-hashes.dat" \
  "$@"

FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

# submit for the rest
"$THIS_DIR/launchpad-submitter" \
  --name trilinos \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases wily xenial \
  --version "$FULL_VERSION" \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos2-submit-hashes.dat" \
  "$@"
