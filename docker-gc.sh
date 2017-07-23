#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

WORK_DIR=$(mktemp -d)
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

ORIG_DIR="$WORK_DIR/orig"
CACHE="$HOME/.cache/repo/docker-gc"
git -C "$CACHE" pull || git clone "https://github.com/spotify/docker-gc.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(cat "$ORIG_DIR/version.txt")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

launchpad-submit \
  --work-dir "$WORK_DIR" \
  --ubuntu-releases trusty xenial zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/docker-gc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
