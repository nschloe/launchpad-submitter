#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DOLFIN_DIR="$HOME/rcs/debian-packages/fenics/dolfin/"
cd "$DOLFIN_DIR" && git pull

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

"$THIS_DIR/../launchpad-submit" \
  --directory "$HOME/rcs/debian-packages/fenics/fenics/" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  "$@"
