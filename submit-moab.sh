#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/moab/source-upstream/"
VERSION=$(grep AC_INIT "$SOURCE_DIR/configure.ac" | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$THIS_DIR/launchpad-submitter" \
  --name moab \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases trusty vivid \
  --debian-prepare 'make' \
  --version "$FULL_VERSION" \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash0.dat" \
  "$@"

FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$THIS_DIR/launchpad-submitter" \
  --name moab \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases wily xenial \
  --debian-prepare 'ADDITIONAL_DEPS=", libmetis-dev, libparmetis-dev" ADDITIONAL_ENABLES="-DENABLE_METIS:BOOL=ON -DENABLE_PARMETIS:BOOL=ON -DMOAB_BUILD_MBPART:BOOL=ON" make' \
  --version "$FULL_VERSION" \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash1.dat" \
  "$@"
