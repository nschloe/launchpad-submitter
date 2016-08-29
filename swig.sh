#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/swig/swig.git" "$ORIG_DIR"

UPSTREAM_VERSION=$(grep 'AC_INIT(' "$ORIG_DIR/configure.ac" | sed 's/^[^0-9]*\([0-9\.]*\).*/\1/')

DEBIAN_DIR=$(mktemp -d)
clone \
   "svn://svn.debian.org/svn/pkg-swig/branches/swig3.0" \
   "$DEBIAN_DIR"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty xenial yakkety \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/swig-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
