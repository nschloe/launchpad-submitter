#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/git/git.git" "$ORIG_DIR"

cd "$ORIG_DIR"
./GIT-VERSION-GEN > /dev/null 2>&1
UPSTREAM_VERSION=$(cat GIT-VERSION-FILE | sed 's/[^0-9]*\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g')

DEBIAN_DIR=$(mktemp -d)
GIT_SSL_NO_VERIFY=1 clone "https://repo.or.cz/r/git/debian.git/" "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/git-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
