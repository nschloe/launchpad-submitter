#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/dolfin/pristine/"
cd "$SOURCE_DIR" && git pull

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/fenics/dolfin/debian/"
cd "$DEBIAN_DIR" && git pull
sed -i "/python-netcdf/d" control
sed -i "/slepc-dev/d" control

DIR="/tmp/dolfin"
rm -rf "$DIR"
"$HOME/rcs/launchpad-tools/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily \
  --version "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg" \
  --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
  "$@"

cd "$DEBIAN_DIR" && git checkout .
sed -i "/python-netcdf/d" control

rm -rf "$DIR"
"$HOME/rcs/launchpad-tools/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg" \
  --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
  "$@"

cd "$DEBIAN_DIR" && git checkout .
