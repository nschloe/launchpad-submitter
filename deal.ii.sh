#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/dealii"
git -C "$CACHE" pull || git clone "https://github.com/dealii/dealii.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/VERSION")

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/dealii-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/deal.ii.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i '/doc\/doxygen\/deal.II\/images/d' "$DEBIAN_DIR/rules"
sed -i '/getElementById/,+2 d' "$DEBIAN_DIR/rules"
sed -i '/step-35/d' "$DEBIAN_DIR/rules"
sed -i '/glossary/d' "$DEBIAN_DIR/rules"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d")" \
  --version-append-hash \
  --ppa nschloe/deal.ii-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
