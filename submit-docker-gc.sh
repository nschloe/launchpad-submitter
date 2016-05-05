#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/docker-gc/upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(cat "$SOURCE_DIR/version.txt")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

HASH=$(git show --pretty=format:'%T')
HASHFILE="$THIS_DIR/docker-gc-submit-hash.dat"
if [ "$HASH" = "$(cat "$HASHFILE")" ]; then
  echo "Already submitted."
  exit 1
fi

"$THIS_DIR/launchpad-submit" \
  --directory "$SOURCE_DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/docker-gc-nightly \
  "$@"

# Update hash
echo "$HASH" > "$HASHFILE"
