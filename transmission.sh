#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/transmission"
git -C "$CACHE" pull || git clone "https://github.com/transmission/transmission.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

# get version
UPSTREAM_VERSION=$(grep -i "set(TR_USER_AGENT_PREFIX" "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9\.]*\).*/\1/')
VERSION="$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/transmission-debian"
git -C "$CACHE" pull || git clone "git://anonscm.debian.org/collab-maint/transmission.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/Build-Depends:/Build-Depends: xfslibs-dev,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/transmission-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
