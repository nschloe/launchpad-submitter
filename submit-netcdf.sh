#!/bin/sh -ue

# Set SSH agent variables.
eval "$(cat "$HOME/.ssh/agent/info")"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf/source-upstream/"
VERSION=$(grep "^AC_INIT" "$SOURCE_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

"$THIS_DIR/launchpad-submitter" \
  --name netcdf \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf/debian/" \
  --ubuntu-releases precise trusty vivid wily xenial \
  --version "$VERSION" \
  --slot 1 \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdf-submit-hash-unstable.dat"
