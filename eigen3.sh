#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# HG doesn't properly update yet. (bug?)
ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/eigen"
git -C "$CACHE" pull || git clone "https://github.com/RLovelett/eigen.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep '#define EIGEN_WORLD_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep '#define EIGEN_MAJOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep '#define EIGEN_MINOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/eigen-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/eigen3.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial yakkety zesty artful \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/eigen-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
