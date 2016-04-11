#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf/source-upstream/"
VERSION=$(grep "^AC_INIT" "$SOURCE_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
sed -i \"/hdf5-library-path.patch/d\" patches/series; \
"
"$THIS_DIR/launchpad-submitter" \
  --name netcdf \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases precise trusty wily xenial \
  --version "$FULL_VERSION" \
  --slot 1 \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdf-submit-hash-unstable.dat"
