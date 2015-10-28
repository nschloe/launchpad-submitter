#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

$THIS_DIR/launchpad-submitter \
  --name moab \
  --resubmission 1 \
  --source-dir "$HOME/software/moab/source-upstream/" \
  --ubuntu-releases trusty vivid \
  --debian-prepare 'make' \
  --version-getter 'grep AC_INIT configure.ac | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/"' \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash0.dat" \
  "$@"

$THIS_DIR/launchpad-submitter \
  --name moab \
  --resubmission 1 \
  --source-dir "$HOME/software/moab/source-upstream/" \
  --ubuntu-releases wily xenial \
  --debian-prepare 'ADDITIONAL_DEPS=", libmetis-dev, libparmetis-dev" ADDITIONAL_ENABLES="-DENABLE_METIS:BOOL=ON -DENABLE_PARMETIS:BOOL=ON" make' \
  --version-getter 'grep AC_INIT configure.ac | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/"' \
  --ppas nschloe/moab-nightly \
  --submit-hashes-file "$THIS_DIR/moab-submit-hash1.dat" \
  "$@"
