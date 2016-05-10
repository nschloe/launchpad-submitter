#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(
  "$HOME/rcs/launchpad-tools/create-debian-repo" \
    --source "git@github.com:Unidata/netcdf-cxx4.git" \
    --debian "git://anonscm.debian.org/git/pkg-grass/netcdf-cxx.git"
  )

VERSION=$(grep "^AC_INIT" $DIR/configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/netcdf-nightly \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  --debuild-params="-p$THIS_DIR/mygpg" \
  "$@"

rm -rf "$DIR"
