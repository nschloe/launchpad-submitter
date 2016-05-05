#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# SOURCE_DIR="$HOME/software/fenics/ffc/upstream/"
# cd "$SOURCE_DIR" && git pull
SOURCE_DIR="$HOME/software/fenics/ffc/source-nschloe/"

VERSION=$(grep '__version__ =' "$SOURCE_DIR/ffc/__init__.py" | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/fenics/ffc/debian/"
cd "$DEBIAN_DIR" && git pull
sed -i "/fix-ufc-config.patch/d" patches/series
sed -i "/ufc-1.pc/d" rules

DIR="/tmp/ffc"
rm -rf "$DIR"
"$THIS_DIR/../create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

"$THIS_DIR/../launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  "$@"

cd "$DEBIAN_DIR" && git checkout .
