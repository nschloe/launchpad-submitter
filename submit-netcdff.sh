#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

"$THIS_DIR/launchpad-submitter" \
  --name netcdff \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-fortran/source-upstream/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-fortran/" \
  --ubuntu-releases trusty vivid wily xenial \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdff-submit-hash-unstable.dat" \
  "$@"
