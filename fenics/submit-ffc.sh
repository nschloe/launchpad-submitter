#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# SOURCE_DIR="$HOME/software/fenics/ffc/upstream/"
SOURCE_DIR="$HOME/software/fenics/ffc/source-nschloe/"

VERSION=$(grep '__version__ =' "$SOURCE_DIR/ffc/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="/tmp/debian-ffc"
rm -rf "$DEBIAN_DIR"
cp -r "$HOME/rcs/debian-packages/fenics/ffc/debian/" "$DEBIAN_DIR"
cd "$DEBIAN_DIR"
sed -i "/fix-ufc-config.patch/d" patches/series
sed -i "/ufc-1.pc/d" rules

"$THIS_DIR/../launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/fenics-nightly \
  --submit-hashes-file "$THIS_DIR/ffc-submit-hash.dat" \
  "$@"
