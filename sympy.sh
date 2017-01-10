#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/sympy/sympy.git" \
  "$ORIG_DIR"

UPSTREAM_VERSION=$(sed 's/[^\"]*\"\([^\"]*\)\".*/\1/' "$ORIG_DIR/sympy/release.py")

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
   "git://anonscm.debian.org/git/debian-science/packages/sympy.git" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/sympy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
