#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# HG doesn't properly update yet. (bug?)
ORIG_DIR="$TMP_DIR/orig"
# clone "ssh://hg@bitbucket.org/eigen/eigen" "$ORIG_DIR"
clone --ignore-hidden \
  "https://github.com/RLovelett/eigen.git" \
  "$ORIG_DIR"

MAJOR=$(grep '#define EIGEN_WORLD_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep '#define EIGEN_MAJOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep '#define EIGEN_MINOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
clone \
  --subdirectory=debian/ \
  "git://anonscm.debian.org/git/debian-science/packages/eigen3.git" \
  "$DEBIAN_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/eigen-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
