#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/transmission/transmission.git" "$ORIG_DIR"

# get version
UPSTREAM_VERSION=$(grep -i "set(TR_USER_AGENT_PREFIX" "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9\.]*\).*/\1/')
VERSION="$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone "git://anonscm.debian.org/collab-maint/transmission.git" "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/transmission-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
