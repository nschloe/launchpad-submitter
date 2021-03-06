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
VERSION="3.0+git$(date +"%Y%m%d%H%M")"

# TODO use debian upstream
CACHE="$HOME/.cache/repo/xdmf-debian"
git -C "$CACHE" pull || git clone "https://github.com/nschloe/debian-xdmf.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_DIR="$ORIG_DIR/debian"
sed -i "s/Examples/examples/g" "$DEBIAN_DIR/libxdmf-dev.examples"
sed -i "/Data/d" "$DEBIAN_DIR/libxdmf-dev.examples"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful bionic \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/xdmf-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
