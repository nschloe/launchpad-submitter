#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION=$(grep "^AC_INIT" configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/")

"$THIS_DIR/launchpad-submitter" \
  --name netcdfcxx \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-cxx/source-upstream/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-cxx/" \
  --ubuntu-releases trusty vivid wily xenial \
  --version "$VERSION" \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdfcxx-submit-hash-unstable.dat" \
  "$@"
