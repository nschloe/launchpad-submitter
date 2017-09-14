#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/seacas"
git -C "$CACHE" pull || git clone "https://github.com/gsjaardema/seacas.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep "SEACASProj_VERSION " "$ORIG_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"

DEBIAN_DIR="$ORIG_DIR/debian"
sed -i "s/-DTPL_ENABLE_ParMETIS:BOOL=ON/-DTPL_ENABLE_ParMETIS:BOOL=OFF/g" "$DEBIAN_DIR/rules"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/seacas-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
