#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/lmms"
git -C "$CACHE" pull || git clone "https://github.com/LMMS/lmms.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'SET(VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'SET(VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
RELEASE=$(grep 'SET(VERSION_RELEASE ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$RELEASE~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/lmms-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-edu/pkg-team/lmms.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_DIR="$ORIG_DIR/debian"
sed -i '/data.lmms\.png/d' "$DEBIAN_DIR/lmms.install"
sed -i '/CoolSongs/d' "$DEBIAN_DIR/lmms-common.install"
sed -i '/Demos/d' "$DEBIAN_DIR/lmms-common.install"
sed -i '/Shorties/d' "$DEBIAN_DIR/lmms-common.install"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty artful \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/lmms-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
