#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Get version from Dolfin
DOLFIN_DIR="$TMP_DIR/dolfin"
clone --ignore-hidden \
  "https://bitbucket.org/fenics-project/dolfin.git" \
  "$DOLFIN_DIR"
MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

FENICS_DIR="$TMP_DIR/fenics"
clone --ignore-hidden \
  "git://anonscm.debian.org/git/debian-science/packages/fenics/fenics.git" \
  "$FENICS_DIR"

launchpad-submit \
  --work-dir "$FENICS_DIR" \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --ubuntu-releases trusty xenial yakkety zesty \
  --debuild-params="-p$THIS_DIR/../mygpg"
