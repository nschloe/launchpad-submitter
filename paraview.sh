#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/Kitware/ParaView.git" \
  "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/version.txt")
VERSION="$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
  "https://anonscm.debian.org/git/debian-science/packages/paraview.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/paraview-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
