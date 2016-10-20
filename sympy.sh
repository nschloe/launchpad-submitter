#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/sympy/sympy.git" "$ORIG_DIR"

UPSTREAM_VERSION=$(sed 's/[^\"]*\"\([^\"]*\)\".*/\1/' "$ORIG_DIR/sympy/release.py")

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/debian-science/packages/sympy.git" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/sympy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
