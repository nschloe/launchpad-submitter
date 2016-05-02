#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/fiat/upstream/"

VERSION=$(grep '__version__ =' "$SOURCE_DIR/FIAT/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
"
"$THIS_DIR/../launchpad-submitter" \
  --debian-dir "$HOME/rcs/debian-packages/fenics/fiat/debian/" \
  --source-dir "$SOURCE_DIR" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/fiat-submit-hash.dat" \
  "$@"
