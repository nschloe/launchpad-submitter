#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "git@github.com:Kitware/ParaView.git" "$ORIG_DIR"

# get version
MAJOR=$(grep 'set (PARAVIEW_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep 'set (PARAVIEW_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep 'set (PARAVIEW_VERSION_PATCH ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^.*\([0-9]\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone "git://anonscm.debian.org/debian-science/packages/paraview.git" "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/paraview-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
