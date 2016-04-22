#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf-fortran/source-upstream/"
VERSION=$(grep "^AC_INIT" "$SOURCE_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
sed -i \"/privacy-breach-logo.patch/d\" patches/series; \
"
"$THIS_DIR/launchpad-submitter" \
  --name netcdf-fortran \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/netcdf-fortran/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/netcdf-nightly \
  --submit-hashes-file "$THIS_DIR/netcdff-submit-hash-unstable.dat" \
  "$@"
