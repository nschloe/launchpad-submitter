#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/xdmf"
git -C "$CACHE" pull || git clone "https://gitlab.kitware.com/xdmf/xdmf.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

# No idea how to extract version yet. Set 3.0.
UPSTREAM_VERSION="3.0~$(date +"%Y%m%d%H%M%S")"

# TODO use debian upstream
CACHE="$HOME/.cache/repo/xdmf-debian"
git -C "$CACHE" pull || git clone "https://github.com/nschloe/debian-xdmf.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/xdmf-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
