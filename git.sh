#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/git"
git -C "$CACHE" pull || git clone "https://github.com/git/git.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

cd "$ORIG_DIR"
./GIT-VERSION-GEN > /dev/null 2>&1
UPSTREAM_VERSION=$(sed 's/[^0-9]*\([0-9]\+\(\.[0-9]\+\)\+\).*/\1/g' GIT-VERSION-FILE)

CACHE="$HOME/.cache/repo/git-debian"
GIT_SSL_NO_VERIFY=1 git -C "$CACHE" pull || GIT_SSL_NO_VERIFY=1 git clone "https://repo.or.cz/r/git/debian.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d")" \
  --version-append-hash \
  --ppa nschloe/git-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
