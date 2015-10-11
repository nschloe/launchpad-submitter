#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

$THIS_DIR/launchpad-submitter \
  --name netcdfcxx \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-cxx/source/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-cxx/" \
  --ubuntu-releases trusty vivid wily \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/"' \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdfcxx-submit-hash-unstable.dat" \
  "$@"
