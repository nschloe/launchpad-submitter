#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/trilinos/source-upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(grep "Trilinos_VERSION " "$SOURCE_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/trilinos/debian/"
cd "$DEBIAN_DIR" && git pull
sed -i '/libhdf5-openmpi-dev/d' control
sed -i '/HDF5/d' rules
sed -i '/libsuperlu-dev/d' control
sed -i '/SuperLU/d' rules

DIR="/tmp/trilinos"
rm -rf "$DIR"
"$HOME/rcs/launchpad-tools/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

cd "$DEBIAN_DIR" && git checkout .

# trusty
"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty \
  --version "$FULL_VERSION" \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
  "$@"

# submit for the rest
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

rm -rf "$DIR"
"$HOME/rcs/launchpad-tools/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
  "$@"
