#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(
  "$HOME/rcs/launchpad-tools/create-debian-repo" \
    --source "git@github.com:trilinos/Trilinos.git" \
    --debian "git://anonscm.debian.org/git/debian-science/packages/trilinos.git"
  )

VERSION=$(grep "Trilinos_VERSION " "$DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

sed -i '/libhdf5-openmpi-dev/d' "$DIR/debian/control"
sed -i '/HDF5/d' "$DIR/debian/rules"
sed -i '/libsuperlu-dev/d' "$DIR/debian/control"
sed -i '/SuperLU/d' "$DIR/debian/rules"
cd "$DIR" && git commit -a -m "update debian"

# trusty
"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty \
  --version "$FULL_VERSION" \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$DIR"

# submit for the rest
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DIR=$(
  "$HOME/rcs/launchpad-tools/create-debian-repo" \
    --source "git@github.com:trilinos/Trilinos.git" \
    --debian "git://anonscm.debian.org/git/debian-science/packages/trilinos.git"
  )

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$DIR"
