#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Get version from Dolfin
DOLFIN_DIR="$TMP_DIR/dolfin"
CACHE="$HOME/.cache/repo/dolfin"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/dolfin.git" "$CACHE"
git clone --shared "$CACHE" "$DOLFIN_DIR"

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d")"

FENICS_DIR="$TMP_DIR/fenics"
CACHE="$HOME/.cache/repo/fenics-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/fenics.git" "$CACHE"
rsync -a "$CACHE/debian" "$FENICS_DIR"

launchpad-submit \
  --work-dir "$FENICS_DIR" \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --ubuntu-releases trusty xenial yakkety zesty artful \
  --debuild-params="-p$THIS_DIR/../mygpg"
