#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "git@github.com:RLovelett/eigen.git" "$ORIG_DIR"

MAJOR=$(grep '#define EIGEN_WORLD_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep '#define EIGEN_MAJOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep '#define EIGEN_MINOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/debian-science/packages/eigen3.git" \
   "$DEBIAN_DIR"

sed -i "/09_fix_1144.patch/d" "$DEBIAN_DIR/debian/patches/series"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/eigen-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
