#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
cleanup() { rm -rf "$DIR"; }
trap cleanup EXIT

clone --ignore-hidden \
  "https://github.com/spotify/docker-gc.git" \
  "$DIR/orig"

VERSION=$(cat "$DIR/orig/version.txt")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

launchpad-submit \
  --work-dir "$DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/docker-gc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
