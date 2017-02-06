#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/swig"
git -C "$CACHE" pull || git clone "https://github.com/swig/swig.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

UPSTREAM_VERSION=$(grep 'AC_INIT(' "$ORIG_DIR/configure.ac" | sed 's/^[^0-9]*\([0-9\.]*\).*/\1/')

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/swig-debian"
(cd "$CACHE" && svn up) || svn co "svn://svn.debian.org/svn/pkg-swig/branches/swig3.0" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# remove PHP (unsupported in ubuntu)
sed -i "/php5-cgi,/d" "$DEBIAN_DIR/control"
sed -i "/php5-dev,/d" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/swig-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
