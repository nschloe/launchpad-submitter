#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/trilinos/github/"
VERSION=$(grep "Trilinos_VERSION " "$SOURCE_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

# copy over debian dir and replace respective lines
rm -rf '/tmp/debian-trusty'
cp -r "$HOME/rcs/debian-packages/trilinos/debian/" "/tmp/debian-trusty"
# remove hdf5 support
sed -i '/libhdf5-openmpi-dev/d' '/tmp/debian-trusty/control'
sed -i '/HDF5/d' '/tmp/debian-trusty/rules'
# remove superlu support
sed -i '/libsuperlu-dev/d' '/tmp/debian-trusty/control'
sed -i '/SuperLU/d' '/tmp/debian-trusty/rules'

# trusty
"$THIS_DIR/launchpad-submitter" \
  --name trilinos \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "/tmp/debian-trusty/" \
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
  --debian-dir "$HOME/rcs/debian-packages/trilinos/debian/" \
  --ubuntu-releases vivid wily xenial \
  --version "$FULL_VERSION" \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos2-submit-hashes.dat" \
  "$@"
