#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/gmsh"
(cd "$CACHE" && svn up) || svn co "https://onelab.info/svn/gmsh/trunk" "$CACHE"
rsync -a --exclude ".svn" "$CACHE/" "$ORIG_DIR"

MAJOR=$(grep 'set(GMSH_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(GMSH_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(GMSH_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/gmsh-debian"
git -C "$CACHE" pull || git clone "git://anonscm.debian.org/git/debian-science/packages/gmsh.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "s/Build-Depends:/Build-Depends: libmetis-dev,/" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/gmsh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
