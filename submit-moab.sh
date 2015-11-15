#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/moab/source-upstream/"
VERSION=$(grep AC_INIT "$SOURCE_DIR/configure.ac" | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/")

"$THIS_DIR/launchpad-submitter" \
  --name moab \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases trusty vivid \
  --debian-prepare 'make' \
  --version "$VERSION" \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash0.dat" \
  "$@"

# Wait at least a minute to make sure that the below submission gets another
# timestamp. Otherwise, the upload will be rejected with
# ```
# Rejected:
# File moab_4.8.3pre~201510280949.orig.tar.gz already exists in MOAB nightly,
# but uploaded version has different contents.
# ```
sleep 60

"$THIS_DIR/launchpad-submitter" \
  --name moab \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases wily xenial \
  --debian-prepare 'ADDITIONAL_DEPS=", libmetis-dev, libparmetis-dev" ADDITIONAL_ENABLES="-DENABLE_METIS:BOOL=ON -DENABLE_PARMETIS:BOOL=ON -DMOAB_BUILD_MBPART:BOOL=ON" make' \
  --version "$VERSION" \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash1.dat" \
  "$@"
