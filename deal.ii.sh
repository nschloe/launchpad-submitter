#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/dealii/dealii.git" \
  "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/VERSION")

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
  "https://anonscm.debian.org/git/debian-science/packages/deal.ii.git" \
  "$DEBIAN_DIR"

sed -i '/doc\/doxygen\/deal.II\/images/d' "$DEBIAN_DIR/debian/rules"
sed -i '/getElementById/,+2 d' "$DEBIAN_DIR/debian/rules"
sed -i '/step-35/d' "$DEBIAN_DIR/debian/rules"
sed -i '/glossary/d' "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/deal.ii-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
