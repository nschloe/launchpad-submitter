#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf-cxx/source-upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(grep "^AC_INIT" $SOURCE_DIR/configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/netcdf-cxx/debian/"
cd "$DEBIAN_DIR" && git pull

DIR="/tmp/netcdfcxx"
rm -rf "$DIR"
"$THIS_DIR/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$THIS_DIR/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/netcdf-nightly \
  "$@"
