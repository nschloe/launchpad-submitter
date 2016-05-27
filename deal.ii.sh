#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/dealii/dealii.git" "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/VERSION")

DEBIAN_DIR=$(mktemp -d)
clone \
  "https://anonscm.debian.org/git/debian-science/packages/deal.ii.git" \
  "$DEBIAN_DIR"

sed -i '/doc\/doxygen\/deal.II\/images/d' "$DEBIAN_DIR/debian/rules"
sed -i '/getElementById/,+2 d' "$DEBIAN_DIR/debian/rules"
sed -i '/step-35/d' "$DEBIAN_DIR/debian/rules"
sed -i '/glossary/d' "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases yakkety \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/deal.ii-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
