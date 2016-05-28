#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
clone "https://github.com/docker/docker.git" "$DIR"

VERSION=$(cat "$DIR/version.txt")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --orig "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/docker-gc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$DIR"
