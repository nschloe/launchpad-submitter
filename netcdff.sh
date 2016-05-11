#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/create-debian-repo" \
  --orig "git@github.com:Unidata/netcdf-fortran.git" \
  --debian "git://anonscm.debian.org/git/pkg-grass/netcdf-fortran.git" \
  --out "$DIR"

VERSION=$(grep "^AC_INIT" "$DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/netcdf-nightly \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  --debuild-params="-p$THIS_DIR/mygpg" \
  "$@"

rm -rf "$DIR"
