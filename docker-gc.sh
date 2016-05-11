#!/bin/sh -ue

. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/create-debian-repo" \
  --orig "git@github.com:spotify/docker-gc.git" \
  --out "$DIR"

VERSION=$(cat "$DIR/version.txt")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$HOME/rcs/launchpadtools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --slot "2" \
  --ppa nschloe/docker-gc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$DIR"
