#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
DEBIAN_DIR=$(mktemp -d)
# cleanup even if launchpad-submit fails
cleanup() { rm -rf "$ORIG_DIR" "$DEBIAN_DIR"; }
trap cleanup EXIT

clone "https://github.com/git/git.git" "$ORIG_DIR"

cd "$ORIG_DIR"
./GIT-VERSION-GEN > /dev/null 2>&1
UPSTREAM_VERSION=$(cat GIT-VERSION-FILE | sed 's/[^0-9]*\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g')

GIT_SSL_NO_VERIFY=1 clone "https://repo.or.cz/r/git/debian.git/" "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/git-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
