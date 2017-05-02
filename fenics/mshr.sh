#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/mshr"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/mshr.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'MSHR_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'MSHR_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'MSHR_VERSION_MICRO ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/mshr-debian"
git -C "$CACHE" pull || git clone "git://anonscm.debian.org/git/debian-science/packages/fenics/mshr.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i 's/Build-Depends:/Build-Depends: python-petsc4py, python-slepc4py,/g' "$ORIG_DIR/debian/control"

sed -i "/mshrable/d" "$DEBIAN_DIR/libmshr-dev.install"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases yakkety zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
