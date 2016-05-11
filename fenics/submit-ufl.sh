#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/ufl/upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(grep '__version__ =' "$SOURCE_DIR/ufl/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/fenics/ufl/debian/"
cd "$DEBIAN_DIR" && git pull

DIR="/tmp/ufl"
rm -rf "$DIR"
"$THIS_DIR/../create-debian-repo" \
  --orig "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$THIS_DIR/../launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  "$@"
