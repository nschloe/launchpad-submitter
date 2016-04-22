#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/ufl/upstream/"

VERSION=$(grep '__version__ =' "$SOURCE_DIR/ufl/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
"
"$THIS_DIR/../launchpad-submitter" \
  --name ufl \
  --debian-dir "$HOME/software/debian-science-fenics/github/ufl/trunk/debian/" \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/ufl-submit-hash.dat" \
  "$@"
