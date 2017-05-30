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
FULL_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d%H%M")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/mshr-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/mshr.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9]\).*/\1/')
sed -i "s/libdolfin$DEBIAN_VERSION/libdolfin$MAJOR.$MINOR/g" "$ORIG_DIR/debian/control"

cd "$ORIG_DIR/debian"
rename "s/$DEBIAN_VERSION/$MAJOR.$MINOR/" ./*
rename "s/python-/python3-/" ./*

sed -i 's/Build-Depends:/Build-Depends: python-petsc4py, python-slepc4py,/g' "$ORIG_DIR/debian/control"
sed -i '/X-Python-Version: >= 2.5/a X-Python3-Version: >= 3.4' "$ORIG_DIR/debian/control"
#
sed -i "s/libmshr$DEBIAN_VERSION/libmshr$MAJOR.$MINOR/g" "$ORIG_DIR/debian/control"
# Only python-ffc installs ufc.h, so we need that alongside python3-ffc.
sed -i 's/python-ffc/python-ffc, python3-ffc/g' "$ORIG_DIR/debian/control"
sed -i 's/python-numpy/python3-numpy/g' "$ORIG_DIR/debian/control"
sed -i 's/python-mshr/python3-mshr/g' "$ORIG_DIR/debian/control"
sed -i 's/python-dolfin/python3-dolfin/g' "$ORIG_DIR/debian/control"
#
sed -i 's/--with python2/--with python3/g' "$ORIG_DIR/debian/rules"
sed -i 's/pyversions/py3versions/g' "$ORIG_DIR/debian/rules"
#
sed -i "/mshrable/d" "$DEBIAN_DIR/libmshr-dev.install"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases yakkety zesty artful \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
