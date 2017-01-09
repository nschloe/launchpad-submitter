#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
# cleanup even if launchpad-submit fails
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/git/git.git" \
  "$ORIG_DIR"

cd "$ORIG_DIR"
./GIT-VERSION-GEN > /dev/null 2>&1
UPSTREAM_VERSION=$(cat GIT-VERSION-FILE | sed 's/[^0-9]*\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g')

DEBIAN_DIR="$TMP_DIR/debian"
GIT_SSL_NO_VERIFY=1 clone --ignore-hidden\
  "https://repo.or.cz/r/git/debian.git/" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/git-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
