#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/netcdf/source-upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(grep "^AC_INIT" "$SOURCE_DIR/configure.ac" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$HOME/rcs/debian-packages/netcdf/debian/"
cd "$DEBIAN_DIR" && git pull

DIR="/tmp/netcdf"
rm -rf "$DIR"
"$THIS_DIR/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

cd "$DIR"
HASH=$(git show --pretty=format:'%T')
HASHFILE="$THIS_DIR/netcdf-submit-hash-unstable.dat"
if [ "$HASH" = "$(cat "$HASHFILE")" ]; then
  echo "Already submitted."
  exit 1
fi

"$THIS_DIR/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases precise trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --slot 1 \
  --ppas nschloe/netcdf-nightly \
  "$@"

echo "$HASH" > "$HASHFILE"
