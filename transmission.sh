#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/transmission"
git -C "$CACHE" pull || git clone --recursive "https://github.com/transmission/transmission.git" "$CACHE"
# Don't use local `git clone --shared` here since that doesn't consider the
# submodules.
rsync -a "$CACHE/" "$ORIG_DIR"

# get version
UPSTREAM_VERSION=$(grep -i "set(TR_USER_AGENT_PREFIX" "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9\.]*\).*/\1/')
VERSION="$UPSTREAM_VERSION+git$(date +"%Y%m%d")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/transmission-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/collab-maint/transmission.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/Build-Depends:/Build-Depends: xfslibs-dev,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty artful \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/transmission-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
