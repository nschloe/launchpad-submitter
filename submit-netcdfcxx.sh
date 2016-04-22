#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf-cxx/source-upstream/"
VERSION=$(grep "^AC_INIT" $SOURCE_DIR/configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/")

"$THIS_DIR/launchpad-submitter" \
  --name netcdf-cxx \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-cxx/debian/" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$VERSION" \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdfcxx-submit-hash-unstable.dat" \
  "$@"
