#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

$THIS_DIR/launchpad-submitter \
  --name netcdff \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-fortran/source/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdff/" \
  --ubuntu-releases trusty utopic vivid wily \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdff-submit-hash-unstable.dat"
