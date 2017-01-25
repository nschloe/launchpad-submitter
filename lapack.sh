#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/lapack"
git -C "$CACHE" pull || git clone "https://github.com/Reference-LAPACK/lapack.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'set(LAPACK_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(LAPACK_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(LAPACK_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

CACHE="$HOME/.cache/repo/lapack-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/lapack.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/lapack-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
