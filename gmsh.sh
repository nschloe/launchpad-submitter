#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/gmsh"
git -C "$CACHE" pull || git clone "https://github.com/live-clones/gmsh.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'set(GMSH_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(GMSH_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(GMSH_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH+git$(date +"%Y%m%d%H%M")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/gmsh-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/gmsh.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# sed -i "s/Build-Depends:/Build-Depends: libmetis-dev,/" "$DEBIAN_DIR/control"
# disable occ
# sed -i "s/-DENABLE_OSMESA:BOOL=OFF/-DENABLE_OSMESA:BOOL=OFF -DENABLE_OCC:BOOL=OFF/" "$DEBIAN_DIR/rules"

# Everything before artful: linker errors
launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases artful bionic \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/gmsh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
