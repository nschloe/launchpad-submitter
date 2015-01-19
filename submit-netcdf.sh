#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

$THIS_DIR/launchpad-submitter \
  --name netcdf \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf/dev/pristine/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-official/debian/" \
  --ubuntu-releases precise trusty utopic vivid \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --slot 1 \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdf-submit-hash-unstable.dat"
