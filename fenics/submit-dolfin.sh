#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/dolfin/pristine/"

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="/tmp/debian-dolfin"
rm -rf "$DEBIAN_DIR"
cp -r "$HOME/rcs/debian-packages/fenics/dolfin/debian/" "$DEBIAN_DIR"
cd "$DEBIAN_DIR"
sed -i "/python-netcdf/d" control
sed -i "/slepc-dev/d" control

"$THIS_DIR/../launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases trusty wily \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/dolfin-submit-hash0.dat" \
  "$@"

rm -rf "$DEBIAN_DIR"
cp -r "$HOME/rcs/debian-packages/fenics/dolfin/debian/" "$DEBIAN_DIR"
cd "$DEBIAN_DIR"
sed -i "/python-netcdf/d" control

"$THIS_DIR/../launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/dolfin-submit-hash1.dat" \
  "$@"
