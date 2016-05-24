#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://onelab.info/svn/gmsh/trunk" "$ORIG_DIR"

# get version
MAJOR=$(grep 'set(GMSH_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(GMSH_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(GMSH_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/debian-science/packages/gmsh.git" \
   "$DEBIAN_DIR"

sed -i "s/Build-Depends:/Build-Depends: libmetis-dev,/" "$DEBIAN_DIR/debian/control"
sed -i "/140_fix_java.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/150_fix_texifile.patch/d" "$DEBIAN_DIR/debian/patches/series"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/gmsh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
