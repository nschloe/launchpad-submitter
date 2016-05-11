#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/fenics/mshr/upstream/"
# SOURCE_DIR="$HOME/software/fenics/mshr/source-nschloe/"
cd "$SOURCE_DIR" && git pull

MAJOR=$(grep 'MSHR_VERSION_MAJOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'MSHR_VERSION_MINOR ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'MSHR_VERSION_MICRO ' "$SOURCE_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/fenics/mshr/debian/"
cd "$DEBIAN_DIR" && git pull
sed -i "/mshrable/d" libmshr-dev.install

DIR="/tmp/mshr"
rm -rf "$DIR"
"$HOME/rcs/launchpadtools/create-debian-repo" \
  --orig "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

cd "$DEBIAN_DIR" && git checkout .

"$HOME/rcs/launchpadtools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg" \
  --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
  "$@"
