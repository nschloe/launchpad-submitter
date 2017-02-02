#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/paraview"
git -C "$CACHE" pull || git clone "https://github.com/Kitware/ParaView.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/version.txt")
UPSTREAM_VERSION=$(sanitize-debian-version "$UPSTREAM_VERSION")
VERSION="$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")"

CACHE="$HOME/.cache/repo/paraview-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/paraview.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/Build-Depends:/Build-Depends: gfortran,/" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/paraview-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
